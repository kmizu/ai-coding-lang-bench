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

  def main(argv)
    unless Dir.exist?(MINIGIT_DIR) || (argv[0] == "init")
      # allow init without existing repo
    end

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
    else
      puts "Unknown command: #{argv[0]}"
      1
    end
  end
end
