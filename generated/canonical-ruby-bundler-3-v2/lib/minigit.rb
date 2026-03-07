# frozen_string_literal: true

require "fileutils"

module Minigit
  module_function

  MINIGIT_DIR = ".minigit"
  OBJECTS_DIR = "#{MINIGIT_DIR}/objects"
  COMMITS_DIR = "#{MINIGIT_DIR}/commits"
  INDEX_FILE  = "#{MINIGIT_DIR}/index"
  HEAD_FILE   = "#{MINIGIT_DIR}/HEAD"

  def mini_hash(bytes)
    h = 1469598103934665603
    mod = 2**64
    bytes.each_byte do |b|
      h ^= b
      h = (h * 1099511628211) % mod
    end
    format("%016x", h)
  end

  def cmd_init
    if Dir.exist?(MINIGIT_DIR)
      puts "Repository already initialized"
      return 0
    end
    Dir.mkdir(MINIGIT_DIR)
    Dir.mkdir(OBJECTS_DIR)
    Dir.mkdir(COMMITS_DIR)
    File.write(INDEX_FILE, "")
    File.write(HEAD_FILE, "")
    0
  end

  def cmd_add(file)
    unless File.exist?(file)
      puts "File not found"
      return 1
    end
    content = File.binread(file)
    hash = mini_hash(content)
    File.binwrite("#{OBJECTS_DIR}/#{hash}", content)
    staged = File.read(INDEX_FILE).split("\n")
    unless staged.include?(file)
      File.open(INDEX_FILE, "a") { |f| f.puts(file) }
    end
    0
  end

  def cmd_commit(message)
    staged = File.read(INDEX_FILE).split("\n").reject(&:empty?)
    if staged.empty?
      puts "Nothing to commit"
      return 1
    end

    parent = File.read(HEAD_FILE).strip
    parent = parent.empty? ? "NONE" : parent
    timestamp = Time.now.to_i

    file_lines = staged.sort.map do |fname|
      content = File.binread(fname)
      hash = mini_hash(content)
      "#{fname} #{hash}"
    end.join("\n")

    commit_content = "parent: #{parent}\ntimestamp: #{timestamp}\nmessage: #{message}\nfiles:\n#{file_lines}\n"
    commit_hash = mini_hash(commit_content)

    File.write("#{COMMITS_DIR}/#{commit_hash}", commit_content)
    File.write(HEAD_FILE, commit_hash)
    File.write(INDEX_FILE, "")

    puts "Committed #{commit_hash}"
    0
  end

  def cmd_log
    head = File.read(HEAD_FILE).strip
    if head.empty?
      puts "No commits"
      return 0
    end

    current = head
    while current && !current.empty? && current != "NONE"
      commit_file = "#{COMMITS_DIR}/#{current}"
      break unless File.exist?(commit_file)

      content = File.read(commit_file)
      parent = nil
      timestamp = nil
      message = nil

      content.each_line do |line|
        line.chomp!
        if line.start_with?("parent: ")
          parent = line.sub("parent: ", "")
        elsif line.start_with?("timestamp: ")
          timestamp = line.sub("timestamp: ", "")
        elsif line.start_with?("message: ")
          message = line.sub("message: ", "")
        end
      end

      puts "commit #{current}"
      puts "Date: #{timestamp}"
      puts "Message: #{message}"
      puts ""

      current = (parent == "NONE") ? nil : parent
    end
    0
  end

  def cmd_status
    staged = File.read(INDEX_FILE).split("\n").reject(&:empty?)
    puts "Staged files:"
    if staged.empty?
      puts "(none)"
    else
      staged.each { |f| puts f }
    end
    0
  end

  def parse_commit_files(commit_hash)
    commit_file = "#{COMMITS_DIR}/#{commit_hash}"
    return nil unless File.exist?(commit_file)

    files = {}
    in_files = false
    File.read(commit_file).each_line do |line|
      line.chomp!
      if line == "files:"
        in_files = true
      elsif in_files && !line.empty?
        parts = line.split(" ", 2)
        files[parts[0]] = parts[1] if parts.size == 2
      end
    end
    files
  end

  def cmd_diff(hash1, hash2)
    files1 = parse_commit_files(hash1)
    files2 = parse_commit_files(hash2)

    if files1.nil? || files2.nil?
      puts "Invalid commit"
      return 1
    end

    all_keys = (files1.keys + files2.keys).uniq.sort
    all_keys.each do |fname|
      if files1.key?(fname) && files2.key?(fname)
        puts "Modified: #{fname}" if files1[fname] != files2[fname]
      elsif files2.key?(fname)
        puts "Added: #{fname}"
      else
        puts "Removed: #{fname}"
      end
    end
    0
  end

  def cmd_checkout(commit_hash)
    commit_file = "#{COMMITS_DIR}/#{commit_hash}"
    unless File.exist?(commit_file)
      puts "Invalid commit"
      return 1
    end

    files = parse_commit_files(commit_hash)
    files.each do |fname, blob_hash|
      blob_path = "#{OBJECTS_DIR}/#{blob_hash}"
      content = File.binread(blob_path)
      dir = File.dirname(fname)
      FileUtils.mkdir_p(dir) unless dir == "."
      File.binwrite(fname, content)
    end

    File.write(HEAD_FILE, commit_hash)
    File.write(INDEX_FILE, "")
    puts "Checked out #{commit_hash}"
    0
  end

  def cmd_reset(commit_hash)
    commit_file = "#{COMMITS_DIR}/#{commit_hash}"
    unless File.exist?(commit_file)
      puts "Invalid commit"
      return 1
    end

    File.write(HEAD_FILE, commit_hash)
    File.write(INDEX_FILE, "")
    puts "Reset to #{commit_hash}"
    0
  end

  def cmd_rm(file)
    staged = File.read(INDEX_FILE).split("\n").reject(&:empty?)
    unless staged.include?(file)
      puts "File not in index"
      return 1
    end

    staged.delete(file)
    File.write(INDEX_FILE, staged.empty? ? "" : staged.join("\n") + "\n")
    0
  end

  def cmd_show(commit_hash)
    commit_file = "#{COMMITS_DIR}/#{commit_hash}"
    unless File.exist?(commit_file)
      puts "Invalid commit"
      return 1
    end

    content = File.read(commit_file)
    timestamp = nil
    message = nil
    file_lines = []
    in_files = false

    content.each_line do |line|
      line.chomp!
      if line.start_with?("timestamp: ")
        timestamp = line.sub("timestamp: ", "")
      elsif line.start_with?("message: ")
        message = line.sub("message: ", "")
      elsif line == "files:"
        in_files = true
      elsif in_files && !line.empty?
        file_lines << line
      end
    end

    puts "commit #{commit_hash}"
    puts "Date: #{timestamp}"
    puts "Message: #{message}"
    puts "Files:"
    file_lines.sort.each { |l| puts "  #{l}" }
    0
  end

  def main(argv)
    cmd = argv[0]
    case cmd
    when "init"
      cmd_init
    when "add"
      if argv.size < 2
        warn "Usage: minigit add <file>"
        return 1
      end
      cmd_add(argv[1])
    when "commit"
      if argv[1] == "-m" && argv[2]
        cmd_commit(argv[2])
      else
        warn "Usage: minigit commit -m <message>"
        1
      end
    when "log"
      cmd_log
    when "status"
      cmd_status
    when "diff"
      if argv.size < 3
        warn "Usage: minigit diff <commit1> <commit2>"
        return 1
      end
      cmd_diff(argv[1], argv[2])
    when "checkout"
      if argv.size < 2
        warn "Usage: minigit checkout <commit_hash>"
        return 1
      end
      cmd_checkout(argv[1])
    when "reset"
      if argv.size < 2
        warn "Usage: minigit reset <commit_hash>"
        return 1
      end
      cmd_reset(argv[1])
    when "rm"
      if argv.size < 2
        warn "Usage: minigit rm <file>"
        return 1
      end
      cmd_rm(argv[1])
    when "show"
      if argv.size < 2
        warn "Usage: minigit show <commit_hash>"
        return 1
      end
      cmd_show(argv[1])
    else
      warn "Unknown command: #{cmd}"
      1
    end
  end
end
