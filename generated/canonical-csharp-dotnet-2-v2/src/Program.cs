using System;
using System.IO;
using System.Linq;
using System.Text;

// args is provided by top-level program feature
if (args.Length == 0)
{
    Console.Error.WriteLine("Usage: minigit <command>");
    Environment.Exit(1);
}

switch (args[0])
{
    case "init":
        Init();
        break;
    case "add":
        if (args.Length < 2) { Console.Error.WriteLine("Usage: minigit add <file>"); Environment.Exit(1); }
        Add(args[1]);
        break;
    case "commit":
        if (args.Length < 3 || args[1] != "-m") { Console.Error.WriteLine("Usage: minigit commit -m <message>"); Environment.Exit(1); }
        Commit(args[2]);
        break;
    case "log":
        Log();
        break;
    case "status":
        Status();
        break;
    case "diff":
        if (args.Length < 3) { Console.Error.WriteLine("Usage: minigit diff <commit1> <commit2>"); Environment.Exit(1); }
        Diff(args[1], args[2]);
        break;
    case "checkout":
        if (args.Length < 2) { Console.Error.WriteLine("Usage: minigit checkout <commit_hash>"); Environment.Exit(1); }
        Checkout(args[1]);
        break;
    case "reset":
        if (args.Length < 2) { Console.Error.WriteLine("Usage: minigit reset <commit_hash>"); Environment.Exit(1); }
        Reset(args[1]);
        break;
    case "rm":
        if (args.Length < 2) { Console.Error.WriteLine("Usage: minigit rm <file>"); Environment.Exit(1); }
        Rm(args[1]);
        break;
    case "show":
        if (args.Length < 2) { Console.Error.WriteLine("Usage: minigit show <commit_hash>"); Environment.Exit(1); }
        Show(args[1]);
        break;
    default:
        Console.Error.WriteLine($"Unknown command: {args[0]}");
        Environment.Exit(1);
        break;
}

static string MiniHash(byte[] data)
{
    ulong h = 1469598103934665603UL;
    foreach (byte b in data)
    {
        h ^= b;
        unchecked { h *= 1099511628211UL; }
    }
    return h.ToString("x16");
}

static void Init()
{
    string minigit = ".minigit";
    if (Directory.Exists(minigit))
    {
        Console.WriteLine("Repository already initialized");
        Environment.Exit(0);
    }
    Directory.CreateDirectory(Path.Combine(minigit, "objects"));
    Directory.CreateDirectory(Path.Combine(minigit, "commits"));
    File.WriteAllText(Path.Combine(minigit, "index"), "");
    File.WriteAllText(Path.Combine(minigit, "HEAD"), "");
}

static void Add(string filename)
{
    if (!File.Exists(filename))
    {
        Console.WriteLine("File not found");
        Environment.Exit(1);
    }
    byte[] content = File.ReadAllBytes(filename);
    string hash = MiniHash(content);
    string blobPath = Path.Combine(".minigit", "objects", hash);
    File.WriteAllBytes(blobPath, content);

    string indexPath = Path.Combine(".minigit", "index");
    string[] staged = File.Exists(indexPath) ? File.ReadAllLines(indexPath) : Array.Empty<string>();
    if (!staged.Contains(filename))
    {
        File.AppendAllText(indexPath, filename + "\n");
    }
}

static void Commit(string message)
{
    string indexPath = Path.Combine(".minigit", "index");
    string[] staged = File.Exists(indexPath)
        ? File.ReadAllLines(indexPath).Where(l => l.Length > 0).ToArray()
        : Array.Empty<string>();

    if (staged.Length == 0)
    {
        Console.WriteLine("Nothing to commit");
        Environment.Exit(1);
    }

    string headPath = Path.Combine(".minigit", "HEAD");
    string parent = File.Exists(headPath) ? File.ReadAllText(headPath).Trim() : "";
    string parentStr = parent.Length > 0 ? parent : "NONE";

    long timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

    var sb = new StringBuilder();
    sb.AppendLine($"parent: {parentStr}");
    sb.AppendLine($"timestamp: {timestamp}");
    sb.AppendLine($"message: {message}");
    sb.AppendLine("files:");

    // Compute blob hashes for each staged file, sorted lexicographically
    var fileEntries = staged
        .OrderBy(f => f)
        .Select(f =>
        {
            byte[] bytes = File.ReadAllBytes(f);
            string hash = MiniHash(bytes);
            return $"{f} {hash}";
        })
        .ToArray();

    foreach (var entry in fileEntries)
        sb.AppendLine(entry);

    string commitContent = sb.ToString();
    byte[] commitBytes = Encoding.UTF8.GetBytes(commitContent);
    string commitHash = MiniHash(commitBytes);

    File.WriteAllText(Path.Combine(".minigit", "commits", commitHash), commitContent);
    File.WriteAllText(headPath, commitHash);
    File.WriteAllText(indexPath, "");

    Console.WriteLine($"Committed {commitHash}");
}

static void Log()
{
    string headPath = Path.Combine(".minigit", "HEAD");
    string head = File.Exists(headPath) ? File.ReadAllText(headPath).Trim() : "";

    if (head.Length == 0)
    {
        Console.WriteLine("No commits");
        return;
    }

    string current = head;
    while (current.Length > 0)
    {
        string commitPath = Path.Combine(".minigit", "commits", current);
        if (!File.Exists(commitPath)) break;

        string[] lines = File.ReadAllLines(commitPath);
        string parentHash = "";
        string timestamp = "";
        string commitMessage = "";

        foreach (var line in lines)
        {
            if (line.StartsWith("parent: ")) parentHash = line.Substring("parent: ".Length).Trim();
            else if (line.StartsWith("timestamp: ")) timestamp = line.Substring("timestamp: ".Length).Trim();
            else if (line.StartsWith("message: ")) commitMessage = line.Substring("message: ".Length).Trim();
        }

        Console.WriteLine($"commit {current}");
        Console.WriteLine($"Date: {timestamp}");
        Console.WriteLine($"Message: {commitMessage}");
        Console.WriteLine();

        current = parentHash == "NONE" ? "" : parentHash;
    }
}

static void Status()
{
    string indexPath = Path.Combine(".minigit", "index");
    string[] staged = File.Exists(indexPath)
        ? File.ReadAllLines(indexPath).Where(l => l.Length > 0).ToArray()
        : Array.Empty<string>();

    Console.WriteLine("Staged files:");
    if (staged.Length == 0)
    {
        Console.WriteLine("(none)");
    }
    else
    {
        foreach (var f in staged)
            Console.WriteLine(f);
    }
}

static Dictionary<string, string> ParseCommitFiles(string commitPath)
{
    var files = new Dictionary<string, string>();
    string[] lines = File.ReadAllLines(commitPath);
    bool inFiles = false;
    foreach (var line in lines)
    {
        if (line == "files:")
        {
            inFiles = true;
            continue;
        }
        if (inFiles && line.Length > 0)
        {
            int sp = line.IndexOf(' ');
            if (sp > 0)
            {
                string fname = line.Substring(0, sp);
                string hash = line.Substring(sp + 1).Trim();
                files[fname] = hash;
            }
        }
    }
    return files;
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

    var files1 = ParseCommitFiles(path1);
    var files2 = ParseCommitFiles(path2);

    var allFiles = files1.Keys.Union(files2.Keys).OrderBy(f => f);

    foreach (var file in allFiles)
    {
        bool in1 = files1.ContainsKey(file);
        bool in2 = files2.ContainsKey(file);

        if (in1 && in2)
        {
            if (files1[file] != files2[file])
                Console.WriteLine($"Modified: {file}");
        }
        else if (!in1 && in2)
        {
            Console.WriteLine($"Added: {file}");
        }
        else if (in1 && !in2)
        {
            Console.WriteLine($"Removed: {file}");
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

    var files = ParseCommitFiles(commitPath);
    foreach (var kvp in files)
    {
        string blobPath = Path.Combine(".minigit", "objects", kvp.Value);
        byte[] content = File.ReadAllBytes(blobPath);
        File.WriteAllBytes(kvp.Key, content);
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
    string[] staged = File.Exists(indexPath)
        ? File.ReadAllLines(indexPath).Where(l => l.Length > 0).ToArray()
        : Array.Empty<string>();

    if (!staged.Contains(filename))
    {
        Console.WriteLine("File not in index");
        Environment.Exit(1);
    }

    var newIndex = staged.Where(f => f != filename).ToArray();
    File.WriteAllText(indexPath, newIndex.Length > 0 ? string.Join("\n", newIndex) + "\n" : "");
}

static void Show(string commitHash)
{
    string commitPath = Path.Combine(".minigit", "commits", commitHash);
    if (!File.Exists(commitPath))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    string[] lines = File.ReadAllLines(commitPath);
    string timestamp = "";
    string message = "";
    var files = new Dictionary<string, string>();
    bool inFiles = false;

    foreach (var line in lines)
    {
        if (line.StartsWith("timestamp: ")) timestamp = line.Substring("timestamp: ".Length).Trim();
        else if (line.StartsWith("message: ")) message = line.Substring("message: ".Length).Trim();
        else if (line == "files:") { inFiles = true; continue; }
        else if (inFiles && line.Length > 0)
        {
            int sp = line.IndexOf(' ');
            if (sp > 0)
                files[line.Substring(0, sp)] = line.Substring(sp + 1).Trim();
        }
    }

    Console.WriteLine($"commit {commitHash}");
    Console.WriteLine($"Date: {timestamp}");
    Console.WriteLine($"Message: {message}");
    Console.WriteLine("Files:");
    foreach (var kvp in files.OrderBy(k => k.Key))
        Console.WriteLine($"  {kvp.Key} {kvp.Value}");
}
