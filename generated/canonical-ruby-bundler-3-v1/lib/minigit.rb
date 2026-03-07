# frozen_string_literal: true

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
    else
      warn "Unknown command: #{cmd}"
      1
    end
  end
end
