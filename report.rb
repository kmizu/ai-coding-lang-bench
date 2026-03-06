#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

BASE_DIR = File.expand_path(__dir__)
RESULTS_DIR = File.join(BASE_DIR, 'results')

results_path = File.join(RESULTS_DIR, 'results.json')
meta_path = File.join(RESULTS_DIR, 'meta.json')

abort('results/results.json not found') unless File.exist?(results_path)

results = JSON.parse(File.read(results_path))
meta = File.exist?(meta_path) ? JSON.parse(File.read(meta_path)) : {}

def fmt_number(value)
  value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def stddev(values)
  return 0.0 if values.size <= 1

  mean = values.sum / values.size.to_f
  Math.sqrt(values.sum { |value| (value - mean)**2 } / (values.size - 1).to_f)
end

def claude_field(record, phase, field)
  record["#{phase}_claude"]&.fetch(field, 0) || 0
end

def total_tokens(claude_data)
  return 0 unless claude_data

  (claude_data['input_tokens'] || 0) +
    (claude_data['output_tokens'] || 0) +
    (claude_data['cache_creation_tokens'] || 0) +
    (claude_data['cache_read_tokens'] || 0)
end

def subject_key(record)
  record['subject_id'] || record['language']
end

def subject_label(record)
  record['subject_label'] || record['language'].to_s.capitalize
end

def track(record)
  record['track'] || 'greenfield'
end

def tier(record)
  record['tier'] || 'legacy'
end

def version(record, meta)
  record['tool_version'] || meta.fetch('versions', {}).fetch(subject_key(record), 'unknown')
end

def tier_rank(tier_name)
  {
    'primary' => 0,
    'secondary' => 1,
    'reference' => 2,
    'legacy' => 3
  }.fetch(tier_name, 9)
end

grouped = results.group_by { |record| [track(record), subject_key(record)] }
sorted_groups = grouped.sort_by do |(_, records)|
  sample = records.first
  [track(sample), tier_rank(tier(sample)), subject_label(sample)]
end

report = []
report << '# AI Coding Language Benchmark Report'
report << ''
report << '## Environment'
report << "- Date: #{meta['date'] || 'unknown'}"
report << "- Claude Version: #{meta['claude_version'] || 'unknown'}"
report << "- Last Run Track: #{meta['track'] || 'mixed'}"
report << "- Last Run Seed: #{meta['seed'] || 'unknown'}"
report << ''

report << '## Subjects'
report << '| Track | Tier | Subject | Version |'
report << '|-------|------|---------|---------|'
sorted_groups.each do |(_, records)|
  sample = records.first
  report << "| #{track(sample)} | #{tier(sample)} | #{subject_label(sample)} | #{version(sample, meta)} |"
end
report << ''

report << '## Results Summary'
report << '| Track | Tier | Subject | Trials | Avg Setup | Avg Agent Time | Avg Cost | v1 Tests | v2 Tests |'
report << '|-------|------|---------|--------|-----------|----------------|----------|----------|----------|'

sorted_groups.each do |(_, records)|
  sample = records.first
  n = records.size.to_f
  total_setup = records.sum { |record| (record['v1_setup_time'] || 0) + (record['v2_setup_time'] || 0) }
  total_agent_times = records.map { |record| (record['v1_time'] || 0) + (record['v2_time'] || 0) }
  avg_agent_time = (total_agent_times.sum / n).round(1)
  avg_agent_sd = stddev(total_agent_times).round(1)
  avg_setup = (total_setup / n).round(1)
  avg_cost = records.sum do |record|
    claude_field(record, 'v1', 'cost_usd') + claude_field(record, 'v2', 'cost_usd')
  end / n
  v1_tests = "#{records.count { |record| record['v1_pass'] }}/#{records.size}"
  v2_tests = "#{records.count { |record| record['v2_pass'] }}/#{records.size}"
  report << "| #{track(sample)} | #{tier(sample)} | #{subject_label(sample)} | #{records.size} " \
            "| #{avg_setup}s | #{avg_agent_time}s±#{avg_agent_sd}s | $#{format('%.2f', avg_cost)} | #{v1_tests} | #{v2_tests} |"
end
report << ''

report << '## Token Summary'
report << '| Track | Tier | Subject | Avg Input | Avg Output | Avg Cache Create | Avg Cache Read | Avg Total |'
report << '|-------|------|---------|-----------|------------|------------------|----------------|-----------|'

sorted_groups.each do |(_, records)|
  sample = records.first
  n = records.size.to_f
  sum_input = 0
  sum_output = 0
  sum_cache_create = 0
  sum_cache_read = 0

  records.each do |record|
    %w[v1 v2].each do |phase|
      sum_input += claude_field(record, phase, 'input_tokens')
      sum_output += claude_field(record, phase, 'output_tokens')
      sum_cache_create += claude_field(record, phase, 'cache_creation_tokens')
      sum_cache_read += claude_field(record, phase, 'cache_read_tokens')
    end
  end

  avg_total = ((sum_input + sum_output + sum_cache_create + sum_cache_read) / n).round(0)
  report << "| #{track(sample)} | #{tier(sample)} | #{subject_label(sample)} " \
            "| #{fmt_number((sum_input / n).round(0))} | #{fmt_number((sum_output / n).round(0))} " \
            "| #{fmt_number((sum_cache_create / n).round(0))} | #{fmt_number((sum_cache_read / n).round(0))} " \
            "| #{fmt_number(avg_total)} |"
end
report << ''

report << '## Full Results'
report << '| Track | Tier | Subject | Trial | Setup | Agent | v1 Tests | v2 Tests | Cost |'
report << '|-------|------|---------|-------|-------|-------|----------|----------|------|'

results.sort_by do |record|
  [track(record), tier_rank(tier(record)), subject_label(record), record['trial']]
end.each do |record|
  setup_time = (record['v1_setup_time'] || 0) + (record['v2_setup_time'] || 0)
  agent_time = (record['v1_time'] || 0) + (record['v2_time'] || 0)
  cost = claude_field(record, 'v1', 'cost_usd') + claude_field(record, 'v2', 'cost_usd')
  v1_tests = "#{record['v1_passed_count']}/#{record['v1_total_count']} #{record['v1_pass'] ? 'PASS' : 'FAIL'}"
  v2_tests = "#{record['v2_passed_count']}/#{record['v2_total_count']} #{record['v2_pass'] ? 'PASS' : 'FAIL'}"

  report << "| #{track(record)} | #{tier(record)} | #{subject_label(record)} | #{record['trial']} " \
            "| #{setup_time.round(1)}s | #{agent_time.round(1)}s | #{v1_tests} | #{v2_tests} | $#{format('%.2f', cost)} |"
end
report << ''

report << '## Full Tokens'
report << '| Track | Subject | Trial | Phase | Input | Output | Cache Create | Cache Read | Total | Cost USD |'
report << '|-------|---------|-------|-------|-------|--------|--------------|------------|-------|----------|'

results.sort_by do |record|
  [track(record), tier_rank(tier(record)), subject_label(record), record['trial']]
end.each do |record|
  %w[v1 v2].each do |phase|
    claude_data = record["#{phase}_claude"]
    total = total_tokens(claude_data)
    if claude_data
      report << "| #{track(record)} | #{subject_label(record)} | #{record['trial']} | #{phase} " \
                "| #{fmt_number(claude_data['input_tokens'] || 0)} | #{fmt_number(claude_data['output_tokens'] || 0)} " \
                "| #{fmt_number(claude_data['cache_creation_tokens'] || 0)} | #{fmt_number(claude_data['cache_read_tokens'] || 0)} " \
                "| #{fmt_number(total)} | $#{format('%.4f', claude_data['cost_usd'] || 0)} |"
    else
      report << "| #{track(record)} | #{subject_label(record)} | #{record['trial']} | #{phase} | - | - | - | - | - | - |"
    end
  end
end
report << ''

report_path = File.join(RESULTS_DIR, 'report.md')
File.write(report_path, report.join("\n") + "\n")
puts "Report written to: #{report_path}"
