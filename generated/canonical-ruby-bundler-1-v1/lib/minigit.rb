# frozen_string_literal: true

module Minigit
  MINIGIT_DIR = ".minigit"

  module_function

  def main(argv)
    cmd = argv.shift
    case cmd
    when "init"    then cmd_init
    when "add"     then cmd_add(argv)
    when "commit"  then cmd_commit(argv)
    when "log"     then cmd_log
    else
      warn "Unknown command: #{cmd}"
      1
    end
  end

  # ----------------------------------------
  # MiniHash: FNV-1a variant, 64-bit
  # ----------------------------------------
  def minihash(bytes)
    h = 1469598103934665603
    mod = 2**64
    bytes.each_byte do |b|
      h ^= b
      h = (h * 1099511628211) % mod
    end
    format("%016x", h)
  end

  # ----------------------------------------
  # init
  # ----------------------------------------
  def cmd_init
    if Dir.exist?(MINIGIT_DIR)
      puts "Repository already initialized"
      return 0
    end
    Dir.mkdir(MINIGIT_DIR)
    Dir.mkdir(File.join(MINIGIT_DIR, "objects"))
    Dir.mkdir(File.join(MINIGIT_DIR, "commits"))
    File.write(File.join(MINIGIT_DIR, "index"), "")
    File.write(File.join(MINIGIT_DIR, "HEAD"), "")
    0
  end

  # ----------------------------------------
  # add <file>
  # ----------------------------------------
  def cmd_add(argv)
    filename = argv.first
    unless File.exist?(filename.to_s)
      puts "File not found"
      return 1
    end

    content = File.binread(filename)
    hash = minihash(content)

    blob_path = File.join(MINIGIT_DIR, "objects", hash)
    File.binwrite(blob_path, content) unless File.exist?(blob_path)

    index_path = File.join(MINIGIT_DIR, "index")
    staged = File.read(index_path).split("\n").reject(&:empty?)
    unless staged.include?(filename)
      File.open(index_path, "a") { |f| f.puts filename }
    end

    0
  end

  # ----------------------------------------
  # commit -m "<message>"
  # ----------------------------------------
  def cmd_commit(argv)
    # Parse -m flag
    m_idx = argv.index("-m")
    if m_idx.nil? || argv[m_idx + 1].nil?
      warn "Usage: minigit commit -m <message>"
      return 1
    end
    message = argv[m_idx + 1]

    index_path = File.join(MINIGIT_DIR, "index")
    staged = File.read(index_path).split("\n").reject(&:empty?)

    if staged.empty?
      puts "Nothing to commit"
      return 1
    end

    head_path = File.join(MINIGIT_DIR, "HEAD")
    parent = File.read(head_path).strip
    parent = parent.empty? ? "NONE" : parent

    timestamp = Time.now.to_i

    # Build files section: sorted filenames with their blob hashes
    file_lines = staged.sort.map do |fname|
      content = File.binread(fname)
      hash = minihash(content)
      "#{fname} #{hash}"
    end

    commit_content = <<~COMMIT
      parent: #{parent}
      timestamp: #{timestamp}
      message: #{message}
      files:
      #{file_lines.join("\n")}
    COMMIT

    commit_hash = minihash(commit_content)
    commit_path = File.join(MINIGIT_DIR, "commits", commit_hash)
    File.write(commit_path, commit_content)

    File.write(head_path, commit_hash)
    File.write(index_path, "")

    puts "Committed #{commit_hash}"
    0
  end

  # ----------------------------------------
  # log
  # ----------------------------------------
  def cmd_log
    head_path = File.join(MINIGIT_DIR, "HEAD")
    current = File.read(head_path).strip

    if current.empty?
      puts "No commits"
      return 0
    end

    first = true
    while current && !current.empty? && current != "NONE"
      commit_path = File.join(MINIGIT_DIR, "commits", current)
      break unless File.exist?(commit_path)

      content = File.read(commit_path)
      parent = nil
      timestamp = nil
      message = nil

      content.each_line do |line|
        line = line.chomp
        if line.start_with?("parent: ")
          parent = line.sub("parent: ", "")
        elsif line.start_with?("timestamp: ")
          timestamp = line.sub("timestamp: ", "")
        elsif line.start_with?("message: ")
          message = line.sub("message: ", "")
        end
      end

      puts "" unless first
      first = false
      puts "commit #{current}"
      puts "Date: #{timestamp}"
      puts "Message: #{message}"

      current = (parent == "NONE" ? nil : parent)
    end

    0
  end
end
