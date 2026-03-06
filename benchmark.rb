#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'open3'
require 'optparse'
require 'rbconfig'
require 'shellwords'
require 'time'
require 'timeout'
require 'yaml'

BASE_DIR = File.expand_path(__dir__)
WORK_DIR = File.join(BASE_DIR, 'generated')
RESULTS_DIR = File.join(BASE_DIR, 'results')
LOGS_DIR = File.join(BASE_DIR, 'logs')
TOOLCHAINS_PATH = File.join(BASE_DIR, 'config', 'toolchains.yml')

GO_DIR = File.join(Dir.home, '.local', 'go')
NPM_PREFIX = File.join(Dir.home, '.local', 'npm')

LEGACY_LANGUAGES = {
  'rust' => { exts: %w[rs], version_cmd: 'rustc --version' },
  'go' => { exts: %w[go], version_cmd: "#{GO_DIR}/bin/go version" },
  'c' => { exts: %w[c h], version_cmd: 'gcc --version | head -1' },
  'typescript' => { exts: %w[ts], version_cmd: "#{NPM_PREFIX}/bin/tsx --version" },
  'javascript' => { exts: %w[js], version_cmd: 'node --version' },
  'java' => { exts: %w[java], version_cmd: 'java --version 2>&1 | head -1' },
  'perl' => { exts: %w[pl pm], version_cmd: 'perl --version | head -2 | tail -1' },
  'python' => { exts: %w[py], version_cmd: 'python3 --version' },
  'python/mypy' => {
    exts: %w[py],
    version_cmd: 'python3 --version && mypy --version',
    extra_prompt: 'Write fully type-annotated Python code. All functions must have complete type hints. ' \
                  'After passing the tests, also verify type correctness by running: mypy --strict *.py'
  },
  'ruby' => { exts: %w[rb], version_cmd: 'ruby --version' },
  'ruby/steep' => {
    exts: %w[rb rbs],
    version_cmd: 'ruby --version && steep --version',
    extra_prompt: 'Write Ruby code with RBS type signatures. Create .rbs files for all Ruby source files. ' \
                  'After passing the tests, also verify type correctness by running: steep check'
  },
  'lua' => { exts: %w[lua], version_cmd: 'lua -v' },
  'scheme' => { exts: %w[scm], version_cmd: 'guile --version | head -1' },
  'ocaml' => { exts: %w[ml mli], version_cmd: 'ocaml --version' },
  'haskell' => { exts: %w[hs], version_cmd: 'ghc --version' }
}.freeze

def extra_path
  [File.join(Dir.home, '.cargo', 'bin'), "#{GO_DIR}/bin", "#{NPM_PREFIX}/bin"].uniq.join(':')
end

def run_cmd(cmd, dir: nil, timeout: 600)
  opts = {}
  opts[:chdir] = dir if dir

  stdout = +''
  stderr = +''

  Open3.popen3("export PATH=#{Shellwords.escape(extra_path)}:$PATH && #{cmd}", **opts) do |stdin, out, err, wait_thr|
    stdin.close
    begin
      Timeout.timeout(timeout) do
        out_thread = Thread.new { stdout << out.read.to_s }
        err_thread = Thread.new { stderr << err.read.to_s }
        out_thread.join
        err_thread.join
      end
    rescue Timeout::Error
      Process.kill('TERM', wait_thr.pid) rescue nil
      stderr << "Timeout after #{timeout}s"
    ensure
      out.close unless out.closed?
      err.close unless err.closed?
    end

    status = wait_thr.value
    {
      stdout: stdout,
      stderr: stderr,
      exit_code: status.exitstatus,
      success: status.success?
    }
  end
end

def monotonic_now
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def parse_claude_output(raw_output)
  raw_output = raw_output.dup.force_encoding('UTF-8')
  event = JSON.parse(raw_output.strip)
  return nil unless event.is_a?(Hash) && event['type'] == 'result'

  {
    input_tokens: event['usage']&.fetch('input_tokens', 0) || 0,
    output_tokens: event['usage']&.fetch('output_tokens', 0) || 0,
    cache_creation_tokens: event['usage']&.fetch('cache_creation_input_tokens', 0) || 0,
    cache_read_tokens: event['usage']&.fetch('cache_read_input_tokens', 0) || 0,
    cost_usd: event['cost_usd'] || event['total_cost'] || 0.0,
    num_turns: event['num_turns'] || 0,
    duration_ms: event['duration_ms'] || 0
  }
rescue JSON::ParserError => e
  warn "WARNING: failed to parse Claude JSON output: #{e.message}"
  nil
end

def run_claude(prompt, dir:, log_path: nil)
  cmd = "claude -p #{Shellwords.escape(prompt)} --dangerously-skip-permissions --output-format json"
  started_at = monotonic_now
  result = run_cmd(cmd, dir: dir, timeout: 1_200)
  elapsed = monotonic_now - started_at

  if log_path
    FileUtils.mkdir_p(File.dirname(log_path))
    File.write(log_path, result[:stdout])
  end

  {
    stdout: result[:stdout],
    stderr: result[:stderr],
    success: result[:success],
    elapsed_seconds: elapsed.round(1),
    claude_data: parse_claude_output(result[:stdout])
  }
end

def run_tests(test_script, dir:)
  result = run_cmd("bash #{Shellwords.escape(test_script)}", dir: dir, timeout: 180)
  output = result[:stdout] + result[:stderr]

  {
    success: result[:success],
    passed: output[/PASSED:\s*(\d+)/, 1]&.to_i || 0,
    failed: output[/FAILED:\s*(\d+)/, 1]&.to_i || 0,
    total: output[/TOTAL:\s*(\d+)/, 1]&.to_i || 0,
    output: output
  }
end

def count_loc(dir, exts)
  files = exts.flat_map { |ext| Dir.glob(File.join(dir, '**', "*.#{ext}")) }
  files.reject! { |path| path.include?('/node_modules/') || path.include?('/target/') || path.include?('/dist/') }

  launcher = File.join(dir, 'minigit')
  if File.exist?(launcher) && !files.include?(launcher)
    begin
      content = File.read(launcher, encoding: 'UTF-8')
      files << launcher if content.valid_encoding?
    rescue StandardError
      nil
    end
  end

  files.sum do |path|
    begin
      File.readlines(path).count { |line| !line.strip.empty? }
    rescue StandardError
      0
    end
  end
end

def load_toolchains(path)
  YAML.load_file(path).fetch('toolchains')
end

def legacy_subject(name)
  language, workflow = name.split('/', 2)
  workflow ||= (language == 'scheme' ? 'guile' : 'raw')
  config = LEGACY_LANGUAGES.fetch(name)
  {
    'id' => name,
    'label' => name,
    'language' => language,
    'workflow' => workflow,
    'tier' => 'legacy',
    'canonical' => false,
    'exts' => config[:exts],
    'version_cmd' => config[:version_cmd],
    'extra_prompt' => config[:extra_prompt]
  }
end

def version_for_subject(subject)
  result = run_cmd(subject.fetch('version_cmd'))
  return 'not installed' unless result[:success]

  output = result[:stdout].strip
  output = result[:stderr].strip if output.empty?
  output.lines.map(&:strip).reject(&:empty?).join(' / ')
end

def greenfield_prompt(subject, phase)
  base =
    if phase == 'v1'
      "Implement minigit as described in SPEC-v1.txt using #{subject.fetch('label')}. " \
        "The executable must be named 'minigit' and be runnable as ./minigit. " \
        "For compiled languages, include a Makefile or build script. " \
        "For interpreted languages, ensure the minigit file has a proper shebang line and is executable. " \
        "Verify your implementation passes all tests by running: bash test-v1.sh"
    else
      'Read SPEC-v2.txt and extend the existing minigit implementation with all required commands. ' \
        'Verify your implementation passes all tests by running: bash test-v2.sh'
    end

  [base, subject['extra_prompt']].compact.join(' ')
end

def canonical_prompt(subject, phase)
  spec_name = phase == 'v1' ? 'SPEC-v1.txt' : 'SPEC-v2.txt'
  test_name = phase == 'v1' ? 'test-v1.sh' : 'test-v2.sh'

  base =
    if phase == 'v1'
      "Use the existing #{subject.fetch('label')} project scaffold. " \
        'The benchmark owner already selected the workflow and launcher. ' \
        "Keep the chosen build files intact unless a spec requirement forces a change. " \
        "Implement minigit as described in #{spec_name}. " \
        "Verify your implementation passes all tests by running: bash #{test_name}"
    else
      "Read #{spec_name} and extend the existing project with all required commands. " \
        'Keep the chosen toolchain and project metadata intact unless a spec requirement forces a change. ' \
        "Verify your implementation passes all tests by running: bash #{test_name}"
    end

  [base, subject['extra_prompt']].compact.join(' ')
end

def prepare_workspace(track:, subject:, phase:, dir:, previous_dir: nil, dry_run:)
  started_at = monotonic_now
  FileUtils.rm_rf(dir)

  if phase == 'v2'
    FileUtils.cp_r(previous_dir, dir)
  else
    FileUtils.mkdir_p(dir)
    if track == 'canonical'
      scaffold_cmd = [
        Shellwords.escape(RbConfig.ruby),
        Shellwords.escape(File.join(BASE_DIR, 'scripts', 'scaffold', 'generate_scaffold.rb')),
        '--toolchain',
        Shellwords.escape(subject.fetch('id')),
        '--dir',
        Shellwords.escape(dir)
      ].join(' ')
      result = run_cmd(scaffold_cmd, dir: BASE_DIR, timeout: 180)
      raise "Failed to generate scaffold for #{subject.fetch('id')}: #{result[:stderr]}" unless result[:success]

      setup_cmd = subject['workspace_setup_cmd']
      unless dry_run || setup_cmd.to_s.empty?
        result = run_cmd(setup_cmd, dir: dir, timeout: 1_200)
        raise "Failed to prepare workspace for #{subject.fetch('id')}: #{result[:stderr]}" unless result[:success]
      end
    end
  end

  spec = phase == 'v1' ? 'SPEC-v1.txt' : 'SPEC-v2.txt'
  test = phase == 'v1' ? 'test-v1.sh' : 'test-v2.sh'
  FileUtils.cp(File.join(BASE_DIR, spec), dir)
  FileUtils.cp(File.join(BASE_DIR, test), dir)

  (monotonic_now - started_at).round(1)
end

options = {
  track: 'greenfield',
  trials: 3,
  start: 1,
  dry_run: false,
  seed: 4_242,
  config: TOOLCHAINS_PATH,
  tiers: %w[primary]
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby benchmark.rb [options]'

  opts.on('--track TRACK', 'Benchmark track: greenfield or canonical') { |v| options[:track] = v }
  opts.on('--lang LIST', 'Comma-separated languages for greenfield') { |v| options[:languages] = v.split(',').map(&:strip) }
  opts.on('--toolchains LIST', 'Comma-separated toolchain ids for canonical') { |v| options[:toolchains] = v.split(',').map(&:strip) }
  opts.on('--tiers LIST', 'Comma-separated tiers for canonical (default: primary)') { |v| options[:tiers] = v.split(',').map(&:strip) }
  opts.on('--trials N', Integer, 'Number of trials') { |v| options[:trials] = v }
  opts.on('--start N', Integer, 'Starting trial number') { |v| options[:start] = v }
  opts.on('--seed N', Integer, 'Shuffle seed') { |v| options[:seed] = v }
  opts.on('--config PATH', 'Toolchain config path') { |v| options[:config] = File.expand_path(v, BASE_DIR) }
  opts.on('--dry-run', 'Skip Claude execution and tests') { options[:dry_run] = true }
end.parse!

unless %w[greenfield canonical].include?(options[:track])
  abort("Unsupported track: #{options[:track]}")
end

subjects =
  if options[:track] == 'greenfield'
    selected = options[:languages] || LEGACY_LANGUAGES.keys
    selected.map { |name| legacy_subject(name) }
  else
    toolchains = load_toolchains(options[:config])
    selected =
      if options[:toolchains]&.any?
        toolchains.select { |tc| options[:toolchains].include?(tc.fetch('id')) }
      else
        toolchains.select { |tc| options[:tiers].include?(tc.fetch('tier')) }
      end
    selected
  end

if subjects.empty?
  abort("No subjects selected for track #{options[:track]}")
end

claude_version = run_cmd('claude --version 2>/dev/null || echo unknown')[:stdout].strip

puts '=' * 60
puts 'AI Coding Language Benchmark'
puts '=' * 60
puts "Track: #{options[:track]}"
puts "Subjects: #{subjects.map { |subject| subject.fetch('id') }.join(', ')}"
puts "Trials: #{options[:start]}..#{options[:start] + options[:trials] - 1} (#{options[:trials]} trials)"
puts "Seed: #{options[:seed]}"
puts "Dry run: #{options[:dry_run]}"
puts "Claude Version: #{claude_version}"
puts

versions = {}
puts '--- Subject Versions ---'
subjects.each do |subject|
  versions[subject.fetch('id')] = version_for_subject(subject)
  puts "  #{subject.fetch('id')}: #{versions[subject.fetch('id')]}"
end
puts

FileUtils.mkdir_p(WORK_DIR)
FileUtils.mkdir_p(RESULTS_DIR)
FileUtils.mkdir_p(LOGS_DIR)

unless options[:dry_run]
  puts '--- Warmup ---'
  warmup_dir = File.join(WORK_DIR, '.warmup')
  FileUtils.mkdir_p(warmup_dir)
  warmup = run_claude('Respond with just the word OK.', dir: warmup_dir)
  puts "  Warmup done in #{warmup[:elapsed_seconds]}s (success=#{warmup[:success]})"
  FileUtils.rm_rf(warmup_dir)
  puts
end

results = []

options[:trials].times do |trial_idx|
  trial = options[:start] + trial_idx
  order = subjects.shuffle(random: Random.new(options[:seed] + trial))

  order.each do |subject|
    subject_id = subject.fetch('id')
    dir_name = subject_id.tr('/:', '--')
    v1_dir = File.join(WORK_DIR, "#{options[:track]}-#{dir_name}-#{trial}-v1")
    v2_dir = File.join(WORK_DIR, "#{options[:track]}-#{dir_name}-#{trial}-v2")

    puts '=' * 60
    puts "Trial #{trial} - #{subject_id}"
    puts '=' * 60

    record = {
      track: options[:track],
      subject_id: subject_id,
      subject_label: subject.fetch('label'),
      language: subject.fetch('language'),
      workflow: subject.fetch('workflow'),
      tier: subject.fetch('tier'),
      canonical: subject.fetch('canonical'),
      tool_version: versions.fetch(subject_id),
      trial: trial,
      v1_dir: v1_dir,
      v2_dir: v2_dir,
      v1_setup_time: 0.0,
      v2_setup_time: 0.0,
      v1_time: 0.0,
      v2_time: 0.0,
      v1_pass: false,
      v2_pass: false,
      v1_passed_count: 0,
      v1_failed_count: 0,
      v1_total_count: 0,
      v2_passed_count: 0,
      v2_failed_count: 0,
      v2_total_count: 0,
      v1_loc: 0,
      v2_loc: 0,
      v1_claude: nil,
      v2_claude: nil
    }

    puts "\n--- Phase 1: v1 ---"
    record[:v1_setup_time] = prepare_workspace(track: options[:track], subject: subject, phase: 'v1', dir: v1_dir, dry_run: options[:dry_run])
    puts "  Setup: #{record[:v1_setup_time]}s"

    if options[:dry_run]
      puts "  [DRY RUN] Would run Claude for #{subject_id} v1"
    else
      v1_log = File.join(LOGS_DIR, options[:track], "#{dir_name}-#{trial}-v1.json")
      v1_result = run_claude(options[:track] == 'canonical' ? canonical_prompt(subject, 'v1') : greenfield_prompt(subject, 'v1'),
                             dir: v1_dir, log_path: v1_log)
      record[:v1_time] = v1_result[:elapsed_seconds]
      record[:v1_claude] = v1_result[:claude_data]
      puts "  Claude: #{record[:v1_time]}s"

      test_result = run_tests('test-v1.sh', dir: v1_dir)
      record[:v1_pass] = test_result[:success]
      record[:v1_passed_count] = test_result[:passed]
      record[:v1_failed_count] = test_result[:failed]
      record[:v1_total_count] = test_result[:total]
      record[:v1_loc] = count_loc(v1_dir, subject.fetch('exts'))
      puts "  Tests: #{test_result[:passed]}/#{test_result[:total]} passed"
      puts "  LOC: #{record[:v1_loc]}"
    end

    puts "\n--- Phase 2: v2 ---"
    record[:v2_setup_time] = prepare_workspace(track: options[:track], subject: subject, phase: 'v2', dir: v2_dir,
                                               previous_dir: v1_dir, dry_run: options[:dry_run])
    puts "  Setup: #{record[:v2_setup_time]}s"

    if options[:dry_run]
      puts "  [DRY RUN] Would run Claude for #{subject_id} v2"
    else
      v2_log = File.join(LOGS_DIR, options[:track], "#{dir_name}-#{trial}-v2.json")
      v2_result = run_claude(options[:track] == 'canonical' ? canonical_prompt(subject, 'v2') : greenfield_prompt(subject, 'v2'),
                             dir: v2_dir, log_path: v2_log)
      record[:v2_time] = v2_result[:elapsed_seconds]
      record[:v2_claude] = v2_result[:claude_data]
      puts "  Claude: #{record[:v2_time]}s"

      test_result = run_tests('test-v2.sh', dir: v2_dir)
      record[:v2_pass] = test_result[:success]
      record[:v2_passed_count] = test_result[:passed]
      record[:v2_failed_count] = test_result[:failed]
      record[:v2_total_count] = test_result[:total]
      record[:v2_loc] = count_loc(v2_dir, subject.fetch('exts'))
      puts "  Tests: #{test_result[:passed]}/#{test_result[:total]} passed"
      puts "  LOC: #{record[:v2_loc]}"
    end

    results << record
    puts
  end
end

puts '=' * 60
if options[:dry_run]
  puts 'Dry run finished'
  puts '=' * 60
  puts 'No results were written because --dry-run was enabled.'
  exit 0
end

meta = {
  date: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
  claude_version: claude_version,
  track: options[:track],
  seed: options[:seed],
  trials: options[:trials],
  selected_subjects: subjects.map { |subject| subject.fetch('id') },
  versions: versions
}

File.write(File.join(RESULTS_DIR, 'meta.json'), JSON.pretty_generate(meta))

results_path = File.join(RESULTS_DIR, 'results.json')
existing = File.exist?(results_path) ? JSON.parse(File.read(results_path)) : []
File.write(results_path, JSON.pretty_generate(existing + results.map { |record| record.transform_keys(&:to_s) }))

puts 'Results saved'
puts '=' * 60
puts "Results: #{results_path}"
puts "Meta: #{File.join(RESULTS_DIR, 'meta.json')}"
