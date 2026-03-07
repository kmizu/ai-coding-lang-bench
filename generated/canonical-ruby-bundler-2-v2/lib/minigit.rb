# frozen_string_literal: true

module Minigit
  MINIGIT_DIR = ".minigit"
  MASK64 = (1 << 64) - 1
  FNV_PRIME = 1099511628211
  FNV_OFFSET = 1469598103934665603

  module_function

  def minihash(bytes)
    h = FNV_OFFSET
    bytes.each_byte do |b|
      h ^= b
      h = (h * FNV_PRIME) & MASK64
    end
    format("%016x", h)
  end

  def repo_root
    MINIGIT_DIR
  end

  def objects_dir
    File.join(MINIGIT_DIR, "objects")
  end

  def commits_dir
    File.join(MINIGIT_DIR, "commits")
  end

  def index_path
    File.join(MINIGIT_DIR, "index")
  end

  def head_path
    File.join(MINIGIT_DIR, "HEAD")
  end

  def cmd_init
    if Dir.exist?(MINIGIT_DIR)
      puts "Repository already initialized"
      return 0
    end
    Dir.mkdir(MINIGIT_DIR)
    Dir.mkdir(objects_dir)
    Dir.mkdir(commits_dir)
    File.write(index_path, "")
    File.write(head_path, "")
    0
  end

  def cmd_add(file)
    unless File.exist?(file)
      puts "File not found"
      return 1
    end
    content = File.binread(file)
    hash = minihash(content)
    blob_path = File.join(objects_dir, hash)
    File.binwrite(blob_path, content) unless File.exist?(blob_path)
    indexed = File.read(index_path).split("\n")
    unless indexed.include?(file)
      File.open(index_path, "a") { |f| f.puts(file) }
    end
    0
  end

  def cmd_commit(message)
    indexed = File.read(index_path).split("\n").reject(&:empty?)
    if indexed.empty?
      puts "Nothing to commit"
      return 1
    end
    parent = File.read(head_path).strip
    parent = parent.empty? ? "NONE" : parent
    timestamp = Time.now.to_i
    sorted_files = indexed.sort
    file_lines = sorted_files.map do |f|
      content = File.binread(f)
      hash = minihash(content)
      "#{f} #{hash}"
    end.join("\n")
    commit_content = "parent: #{parent}\ntimestamp: #{timestamp}\nmessage: #{message}\nfiles:\n#{file_lines}\n"
    commit_hash = minihash(commit_content)
    File.write(File.join(commits_dir, commit_hash), commit_content)
    File.write(head_path, commit_hash)
    File.write(index_path, "")
    puts "Committed #{commit_hash}"
    0
  end

  def cmd_log
    head = File.read(head_path).strip
    if head.empty?
      puts "No commits"
      return 0
    end
    current = head
    loop do
      break if current.empty? || current == "NONE"
      path = File.join(commits_dir, current)
      break unless File.exist?(path)
      content = File.read(path)
      timestamp = content[/^timestamp: (.+)$/, 1]
      message = content[/^message: (.+)$/, 1]
      puts "commit #{current}"
      puts "Date: #{timestamp}"
      puts "Message: #{message}"
      puts ""
      parent = content[/^parent: (.+)$/, 1]&.strip
      break if parent.nil? || parent == "NONE"
      current = parent
    end
    0
  end

  def cmd_status
    indexed = File.read(index_path).split("\n").reject(&:empty?)
    puts "Staged files:"
    if indexed.empty?
      puts "(none)"
    else
      indexed.each { |f| puts f }
    end
    0
  end

  def parse_commit_files(content)
    files = {}
    in_files = false
    content.each_line do |line|
      line = line.chomp
      if line == "files:"
        in_files = true
        next
      end
      next unless in_files
      parts = line.split(" ", 2)
      files[parts[0]] = parts[1] if parts.length == 2
    end
    files
  end

  def load_commit(hash)
    path = File.join(commits_dir, hash)
    return nil unless File.exist?(path)
    File.read(path)
  end

  def cmd_diff(hash1, hash2)
    content1 = load_commit(hash1)
    content2 = load_commit(hash2)
    if content1.nil? || content2.nil?
      puts "Invalid commit"
      return 1
    end
    files1 = parse_commit_files(content1)
    files2 = parse_commit_files(content2)
    all_files = (files1.keys + files2.keys).uniq.sort
    all_files.each do |f|
      if files1.key?(f) && files2.key?(f)
        puts "Modified: #{f}" if files1[f] != files2[f]
      elsif files2.key?(f)
        puts "Added: #{f}"
      else
        puts "Removed: #{f}"
      end
    end
    0
  end

  def cmd_checkout(hash)
    content = load_commit(hash)
    if content.nil?
      puts "Invalid commit"
      return 1
    end
    files = parse_commit_files(content)
    files.each do |filename, blob_hash|
      blob_path = File.join(objects_dir, blob_hash)
      File.binwrite(filename, File.binread(blob_path))
    end
    File.write(head_path, hash)
    File.write(index_path, "")
    puts "Checked out #{hash}"
    0
  end

  def cmd_reset(hash)
    content = load_commit(hash)
    if content.nil?
      puts "Invalid commit"
      return 1
    end
    File.write(head_path, hash)
    File.write(index_path, "")
    puts "Reset to #{hash}"
    0
  end

  def cmd_rm(file)
    indexed = File.read(index_path).split("\n").reject(&:empty?)
    unless indexed.include?(file)
      puts "File not in index"
      return 1
    end
    indexed.delete(file)
    File.write(index_path, indexed.map { |f| "#{f}\n" }.join)
    0
  end

  def cmd_show(hash)
    content = load_commit(hash)
    if content.nil?
      puts "Invalid commit"
      return 1
    end
    timestamp = content[/^timestamp: (.+)$/, 1]
    message = content[/^message: (.+)$/, 1]
    files = parse_commit_files(content)
    puts "commit #{hash}"
    puts "Date: #{timestamp}"
    puts "Message: #{message}"
    puts "Files:"
    files.keys.sort.each do |f|
      puts "  #{f} #{files[f]}"
    end
    0
  end

  def main(argv)
    case argv[0]
    when "init"
      cmd_init
    when "add"
      if argv[1].nil?
        puts "Usage: minigit add <file>"
        return 1
      end
      cmd_add(argv[1])
    when "commit"
      if argv[1] == "-m" && argv[2]
        cmd_commit(argv[2])
      else
        puts "Usage: minigit commit -m \"<message>\""
        1
      end
    when "log"
      cmd_log
    when "status"
      cmd_status
    when "diff"
      if argv[1].nil? || argv[2].nil?
        puts "Usage: minigit diff <commit1> <commit2>"
        return 1
      end
      cmd_diff(argv[1], argv[2])
    when "checkout"
      if argv[1].nil?
        puts "Usage: minigit checkout <commit_hash>"
        return 1
      end
      cmd_checkout(argv[1])
    when "reset"
      if argv[1].nil?
        puts "Usage: minigit reset <commit_hash>"
        return 1
      end
      cmd_reset(argv[1])
    when "rm"
      if argv[1].nil?
        puts "Usage: minigit rm <file>"
        return 1
      end
      cmd_rm(argv[1])
    when "show"
      if argv[1].nil?
        puts "Usage: minigit show <commit_hash>"
        return 1
      end
      cmd_show(argv[1])
    else
      puts "Unknown command: #{argv[0]}"
      1
    end
  end
end
