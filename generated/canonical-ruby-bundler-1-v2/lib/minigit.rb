# frozen_string_literal: true

module Minigit
  MINIGIT_DIR = ".minigit"

  module_function

  def main(argv)
    cmd = argv.shift
    case cmd
    when "init"     then cmd_init
    when "add"      then cmd_add(argv)
    when "commit"   then cmd_commit(argv)
    when "status"   then cmd_status
    when "log"      then cmd_log
    when "diff"     then cmd_diff(argv)
    when "checkout" then cmd_checkout(argv)
    when "reset"    then cmd_reset(argv)
    when "rm"       then cmd_rm(argv)
    when "show"     then cmd_show(argv)
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
  # Parse a commit file into a hash
  # ----------------------------------------
  def parse_commit(content)
    result = { parent: nil, timestamp: nil, message: nil, files: {} }
    in_files = false
    content.each_line do |line|
      line = line.chomp
      if in_files
        parts = line.split(" ", 2)
        result[:files][parts[0]] = parts[1] if parts.length == 2
      elsif line.start_with?("parent: ")
        result[:parent] = line.sub("parent: ", "")
      elsif line.start_with?("timestamp: ")
        result[:timestamp] = line.sub("timestamp: ", "")
      elsif line.start_with?("message: ")
        result[:message] = line.sub("message: ", "")
      elsif line == "files:"
        in_files = true
      end
    end
    result
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
  # status
  # ----------------------------------------
  def cmd_status
    index_path = File.join(MINIGIT_DIR, "index")
    staged = File.read(index_path).split("\n").reject(&:empty?)
    puts "Staged files:"
    if staged.empty?
      puts "(none)"
    else
      staged.each { |f| puts f }
    end
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

      info = parse_commit(File.read(commit_path))

      puts "" unless first
      first = false
      puts "commit #{current}"
      puts "Date: #{info[:timestamp]}"
      puts "Message: #{info[:message]}"

      current = (info[:parent] == "NONE" ? nil : info[:parent])
    end

    0
  end

  # ----------------------------------------
  # diff <commit1> <commit2>
  # ----------------------------------------
  def cmd_diff(argv)
    hash1, hash2 = argv[0], argv[1]
    path1 = File.join(MINIGIT_DIR, "commits", hash1.to_s)
    path2 = File.join(MINIGIT_DIR, "commits", hash2.to_s)

    unless File.exist?(path1) && File.exist?(path2)
      puts "Invalid commit"
      return 1
    end

    files1 = parse_commit(File.read(path1))[:files]
    files2 = parse_commit(File.read(path2))[:files]

    all_files = (files1.keys + files2.keys).uniq.sort
    all_files.each do |fname|
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

  # ----------------------------------------
  # checkout <commit_hash>
  # ----------------------------------------
  def cmd_checkout(argv)
    commit_hash = argv.first.to_s
    commit_path = File.join(MINIGIT_DIR, "commits", commit_hash)

    unless File.exist?(commit_path)
      puts "Invalid commit"
      return 1
    end

    info = parse_commit(File.read(commit_path))
    info[:files].each do |fname, blob_hash|
      blob_path = File.join(MINIGIT_DIR, "objects", blob_hash)
      File.binwrite(fname, File.binread(blob_path))
    end

    File.write(File.join(MINIGIT_DIR, "HEAD"), commit_hash)
    File.write(File.join(MINIGIT_DIR, "index"), "")

    puts "Checked out #{commit_hash}"
    0
  end

  # ----------------------------------------
  # reset <commit_hash>
  # ----------------------------------------
  def cmd_reset(argv)
    commit_hash = argv.first.to_s
    commit_path = File.join(MINIGIT_DIR, "commits", commit_hash)

    unless File.exist?(commit_path)
      puts "Invalid commit"
      return 1
    end

    File.write(File.join(MINIGIT_DIR, "HEAD"), commit_hash)
    File.write(File.join(MINIGIT_DIR, "index"), "")

    puts "Reset to #{commit_hash}"
    0
  end

  # ----------------------------------------
  # rm <file>
  # ----------------------------------------
  def cmd_rm(argv)
    filename = argv.first.to_s
    index_path = File.join(MINIGIT_DIR, "index")
    staged = File.read(index_path).split("\n").reject(&:empty?)

    unless staged.include?(filename)
      puts "File not in index"
      return 1
    end

    staged.delete(filename)
    File.write(index_path, staged.empty? ? "" : staged.join("\n") + "\n")
    0
  end

  # ----------------------------------------
  # show <commit_hash>
  # ----------------------------------------
  def cmd_show(argv)
    commit_hash = argv.first.to_s
    commit_path = File.join(MINIGIT_DIR, "commits", commit_hash)

    unless File.exist?(commit_path)
      puts "Invalid commit"
      return 1
    end

    info = parse_commit(File.read(commit_path))
    puts "commit #{commit_hash}"
    puts "Date: #{info[:timestamp]}"
    puts "Message: #{info[:message]}"
    puts "Files:"
    info[:files].keys.sort.each do |fname|
      puts "  #{fname} #{info[:files][fname]}"
    end
    0
  end
end
