using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

if (args.Length == 0)
{
    Console.Error.WriteLine("Usage: minigit <command>");
    Environment.Exit(1);
}

string command = args[0];

switch (command)
{
    case "init":
        Init();
        break;
    case "add":
        if (args.Length < 2)
        {
            Console.Error.WriteLine("Usage: minigit add <file>");
            Environment.Exit(1);
        }
        Add(args[1]);
        break;
    case "commit":
        if (args.Length < 3 || args[1] != "-m")
        {
            Console.Error.WriteLine("Usage: minigit commit -m <message>");
            Environment.Exit(1);
        }
        Commit(args[2]);
        break;
    case "log":
        Log();
        break;
    case "status":
        Status();
        break;
    case "diff":
        if (args.Length < 3)
        {
            Console.Error.WriteLine("Usage: minigit diff <commit1> <commit2>");
            Environment.Exit(1);
        }
        Diff(args[1], args[2]);
        break;
    case "checkout":
        if (args.Length < 2)
        {
            Console.Error.WriteLine("Usage: minigit checkout <commit_hash>");
            Environment.Exit(1);
        }
        Checkout(args[1]);
        break;
    case "reset":
        if (args.Length < 2)
        {
            Console.Error.WriteLine("Usage: minigit reset <commit_hash>");
            Environment.Exit(1);
        }
        Reset(args[1]);
        break;
    case "rm":
        if (args.Length < 2)
        {
            Console.Error.WriteLine("Usage: minigit rm <file>");
            Environment.Exit(1);
        }
        Rm(args[1]);
        break;
    case "show":
        if (args.Length < 2)
        {
            Console.Error.WriteLine("Usage: minigit show <commit_hash>");
            Environment.Exit(1);
        }
        Show(args[1]);
        break;
    default:
        Console.Error.WriteLine($"Unknown command: {command}");
        Environment.Exit(1);
        break;
}

static ulong MiniHash(byte[] data)
{
    ulong h = 1469598103934665603UL;
    foreach (byte b in data)
    {
        h ^= b;
        h = unchecked(h * 1099511628211UL);
    }
    return h;
}

static string HashToHex(ulong h)
{
    return h.ToString("x16");
}

static string ComputeHash(byte[] data)
{
    return HashToHex(MiniHash(data));
}

static void Init()
{
    string minigitDir = ".minigit";
    if (Directory.Exists(minigitDir))
    {
        Console.WriteLine("Repository already initialized");
        Environment.Exit(0);
    }
    Directory.CreateDirectory(minigitDir);
    Directory.CreateDirectory(Path.Combine(minigitDir, "objects"));
    Directory.CreateDirectory(Path.Combine(minigitDir, "commits"));
    File.WriteAllText(Path.Combine(minigitDir, "index"), "");
    File.WriteAllText(Path.Combine(minigitDir, "HEAD"), "");
}

static void Add(string filename)
{
    if (!File.Exists(filename))
    {
        Console.WriteLine("File not found");
        Environment.Exit(1);
    }

    byte[] content = File.ReadAllBytes(filename);
    string hash = ComputeHash(content);

    string objectPath = Path.Combine(".minigit", "objects", hash);
    File.WriteAllBytes(objectPath, content);

    string indexPath = Path.Combine(".minigit", "index");
    string indexContent = File.Exists(indexPath) ? File.ReadAllText(indexPath) : "";
    var lines = indexContent.Split('\n', StringSplitOptions.RemoveEmptyEntries).ToList();
    if (!lines.Contains(filename))
    {
        lines.Add(filename);
        File.WriteAllText(indexPath, string.Join("\n", lines) + "\n");
    }
}

static void Commit(string message)
{
    string indexPath = Path.Combine(".minigit", "index");
    string indexContent = File.Exists(indexPath) ? File.ReadAllText(indexPath) : "";
    var files = indexContent.Split('\n', StringSplitOptions.RemoveEmptyEntries).ToList();

    if (files.Count == 0)
    {
        Console.WriteLine("Nothing to commit");
        Environment.Exit(1);
    }

    string headPath = Path.Combine(".minigit", "HEAD");
    string parent = File.Exists(headPath) ? File.ReadAllText(headPath).Trim() : "";
    if (string.IsNullOrEmpty(parent)) parent = "NONE";

    long timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

    var fileEntries = new List<(string name, string hash)>();
    foreach (var fname in files)
    {
        byte[] content = File.ReadAllBytes(fname);
        string hash = ComputeHash(content);
        fileEntries.Add((fname, hash));
    }

    fileEntries.Sort((a, b) => string.Compare(a.name, b.name, StringComparison.Ordinal));

    var sb = new StringBuilder();
    sb.AppendLine($"parent: {parent}");
    sb.AppendLine($"timestamp: {timestamp}");
    sb.AppendLine($"message: {message}");
    sb.AppendLine("files:");
    foreach (var (name, hash) in fileEntries)
    {
        sb.AppendLine($"{name} {hash}");
    }

    string commitContent = sb.ToString();
    byte[] commitBytes = Encoding.UTF8.GetBytes(commitContent);
    string commitHash = ComputeHash(commitBytes);

    string commitPath = Path.Combine(".minigit", "commits", commitHash);
    File.WriteAllText(commitPath, commitContent);

    File.WriteAllText(headPath, commitHash);
    File.WriteAllText(indexPath, "");

    Console.WriteLine($"Committed {commitHash}");
}

static void Log()
{
    string headPath = Path.Combine(".minigit", "HEAD");
    string head = File.Exists(headPath) ? File.ReadAllText(headPath).Trim() : "";

    if (string.IsNullOrEmpty(head))
    {
        Console.WriteLine("No commits");
        return;
    }

    string current = head;
    while (!string.IsNullOrEmpty(current) && current != "NONE")
    {
        string commitPath = Path.Combine(".minigit", "commits", current);
        if (!File.Exists(commitPath)) break;

        string content = File.ReadAllText(commitPath);
        var lines = content.Split('\n', StringSplitOptions.RemoveEmptyEntries);

        string parent = "";
        string timestamp = "";
        string message = "";

        foreach (var line in lines)
        {
            if (line.StartsWith("parent: ")) parent = line.Substring("parent: ".Length);
            else if (line.StartsWith("timestamp: ")) timestamp = line.Substring("timestamp: ".Length);
            else if (line.StartsWith("message: ")) message = line.Substring("message: ".Length);
        }

        Console.WriteLine($"commit {current}");
        Console.WriteLine($"Date: {timestamp}");
        Console.WriteLine($"Message: {message}");
        Console.WriteLine();

        current = (parent == "NONE" || string.IsNullOrEmpty(parent)) ? "" : parent;
    }
}

static void Status()
{
    string indexPath = Path.Combine(".minigit", "index");
    string indexContent = File.Exists(indexPath) ? File.ReadAllText(indexPath) : "";
    var files = indexContent.Split('\n', StringSplitOptions.RemoveEmptyEntries).ToList();

    Console.WriteLine("Staged files:");
    if (files.Count == 0)
    {
        Console.WriteLine("(none)");
    }
    else
    {
        foreach (var f in files)
            Console.WriteLine(f);
    }
}

static Dictionary<string, string> ParseCommitFiles(string commitContent)
{
    var result = new Dictionary<string, string>();
    bool inFiles = false;
    foreach (var line in commitContent.Split('\n'))
    {
        if (line == "files:")
        {
            inFiles = true;
            continue;
        }
        if (inFiles && !string.IsNullOrEmpty(line))
        {
            int spaceIdx = line.LastIndexOf(' ');
            if (spaceIdx > 0)
            {
                string fname = line.Substring(0, spaceIdx);
                string hash = line.Substring(spaceIdx + 1);
                result[fname] = hash;
            }
        }
    }
    return result;
}

static void Diff(string commit1, string commit2)
{
    string path1 = Path.Combine(".minigit", "commits", commit1);
    string path2 = Path.Combine(".minigit", "commits", commit2);

    if (!File.Exists(path1) || !File.Exists(path2))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    var files1 = ParseCommitFiles(File.ReadAllText(path1));
    var files2 = ParseCommitFiles(File.ReadAllText(path2));

    var allFiles = new SortedSet<string>(files1.Keys.Concat(files2.Keys));

    foreach (var fname in allFiles)
    {
        bool in1 = files1.ContainsKey(fname);
        bool in2 = files2.ContainsKey(fname);

        if (in1 && in2)
        {
            if (files1[fname] != files2[fname])
                Console.WriteLine($"Modified: {fname}");
        }
        else if (!in1 && in2)
        {
            Console.WriteLine($"Added: {fname}");
        }
        else if (in1 && !in2)
        {
            Console.WriteLine($"Removed: {fname}");
        }
    }
}

static void Checkout(string commitHash)
{
    string commitPath = Path.Combine(".minigit", "commits", commitHash);
    if (!File.Exists(commitPath))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    string commitContent = File.ReadAllText(commitPath);
    var files = ParseCommitFiles(commitContent);

    foreach (var (fname, blobHash) in files)
    {
        string blobPath = Path.Combine(".minigit", "objects", blobHash);
        byte[] content = File.ReadAllBytes(blobPath);
        string? dir = Path.GetDirectoryName(fname);
        if (!string.IsNullOrEmpty(dir))
            Directory.CreateDirectory(dir);
        File.WriteAllBytes(fname, content);
    }

    File.WriteAllText(Path.Combine(".minigit", "HEAD"), commitHash);
    File.WriteAllText(Path.Combine(".minigit", "index"), "");

    Console.WriteLine($"Checked out {commitHash}");
}

static void Reset(string commitHash)
{
    string commitPath = Path.Combine(".minigit", "commits", commitHash);
    if (!File.Exists(commitPath))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    File.WriteAllText(Path.Combine(".minigit", "HEAD"), commitHash);
    File.WriteAllText(Path.Combine(".minigit", "index"), "");

    Console.WriteLine($"Reset to {commitHash}");
}

static void Rm(string filename)
{
    string indexPath = Path.Combine(".minigit", "index");
    string indexContent = File.Exists(indexPath) ? File.ReadAllText(indexPath) : "";
    var lines = indexContent.Split('\n', StringSplitOptions.RemoveEmptyEntries).ToList();

    if (!lines.Contains(filename))
    {
        Console.WriteLine("File not in index");
        Environment.Exit(1);
    }

    lines.Remove(filename);
    File.WriteAllText(indexPath, lines.Count > 0 ? string.Join("\n", lines) + "\n" : "");
}

static void Show(string commitHash)
{
    string commitPath = Path.Combine(".minigit", "commits", commitHash);
    if (!File.Exists(commitPath))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    string content = File.ReadAllText(commitPath);
    var lines = content.Split('\n');

    string timestamp = "";
    string message = "";

    foreach (var line in lines)
    {
        if (line.StartsWith("timestamp: ")) timestamp = line.Substring("timestamp: ".Length);
        else if (line.StartsWith("message: ")) message = line.Substring("message: ".Length);
    }

    Console.WriteLine($"commit {commitHash}");
    Console.WriteLine($"Date: {timestamp}");
    Console.WriteLine($"Message: {message}");
    Console.WriteLine("Files:");

    var files = ParseCommitFiles(content);
    foreach (var fname in files.Keys.OrderBy(k => k, StringComparer.Ordinal))
    {
        Console.WriteLine($"  {fname} {files[fname]}");
    }
}
