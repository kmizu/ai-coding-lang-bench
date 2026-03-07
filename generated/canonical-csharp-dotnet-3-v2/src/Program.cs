using System;
using System.IO;
using System.Linq;
using System.Text;

if (args.Length == 0)
{
    Console.Error.WriteLine("Usage: minigit <command> [args]");
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

static string MinigitDir() => Path.Combine(Directory.GetCurrentDirectory(), ".minigit");

static ulong MiniHash(byte[] data)
{
    ulong h = 1469598103934665603UL;
    foreach (byte b in data)
    {
        h ^= b;
        unchecked { h *= 1099511628211UL; }
    }
    return h;
}

static string HashToHex(ulong h) => h.ToString("x16");

static void Init()
{
    string dir = MinigitDir();
    if (Directory.Exists(dir))
    {
        Console.WriteLine("Repository already initialized");
        Environment.Exit(0);
    }
    Directory.CreateDirectory(Path.Combine(dir, "objects"));
    Directory.CreateDirectory(Path.Combine(dir, "commits"));
    File.WriteAllText(Path.Combine(dir, "index"), "");
    File.WriteAllText(Path.Combine(dir, "HEAD"), "");
    Environment.Exit(0);
}

static void Add(string filename)
{
    if (!File.Exists(filename))
    {
        Console.WriteLine("File not found");
        Environment.Exit(1);
    }

    byte[] content = File.ReadAllBytes(filename);
    ulong hashVal = MiniHash(content);
    string hash = HashToHex(hashVal);

    string blobPath = Path.Combine(MinigitDir(), "objects", hash);
    File.WriteAllBytes(blobPath, content);

    string indexPath = Path.Combine(MinigitDir(), "index");
    string[] existing = File.Exists(indexPath) ? File.ReadAllLines(indexPath) : Array.Empty<string>();
    if (!existing.Contains(filename))
    {
        File.AppendAllText(indexPath, filename + "\n");
    }

    Environment.Exit(0);
}

static void Commit(string message)
{
    string indexPath = Path.Combine(MinigitDir(), "index");
    string[] staged = File.Exists(indexPath)
        ? File.ReadAllLines(indexPath).Where(l => !string.IsNullOrEmpty(l)).ToArray()
        : Array.Empty<string>();

    if (staged.Length == 0)
    {
        Console.WriteLine("Nothing to commit");
        Environment.Exit(1);
    }

    string headPath = Path.Combine(MinigitDir(), "HEAD");
    string parent = File.Exists(headPath) ? File.ReadAllText(headPath).Trim() : "";
    if (string.IsNullOrEmpty(parent)) parent = "NONE";

    long timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

    var sortedFiles = staged.OrderBy(f => f).ToArray();
    var sb = new StringBuilder();
    sb.AppendLine($"parent: {parent}");
    sb.AppendLine($"timestamp: {timestamp}");
    sb.AppendLine($"message: {message}");
    sb.AppendLine("files:");
    foreach (string f in sortedFiles)
    {
        byte[] content = File.ReadAllBytes(f);
        ulong hashVal = MiniHash(content);
        string hash = HashToHex(hashVal);
        sb.AppendLine($"{f} {hash}");
    }

    string commitContent = sb.ToString();
    byte[] commitBytes = Encoding.UTF8.GetBytes(commitContent);
    ulong commitHashVal = MiniHash(commitBytes);
    string commitHash = HashToHex(commitHashVal);

    string commitPath = Path.Combine(MinigitDir(), "commits", commitHash);
    File.WriteAllBytes(commitPath, commitBytes);

    File.WriteAllText(headPath, commitHash);
    File.WriteAllText(indexPath, "");

    Console.WriteLine($"Committed {commitHash}");
    Environment.Exit(0);
}

static void Log()
{
    string headPath = Path.Combine(MinigitDir(), "HEAD");
    if (!File.Exists(headPath))
    {
        Console.WriteLine("No commits");
        return;
    }

    string current = File.ReadAllText(headPath).Trim();
    if (string.IsNullOrEmpty(current))
    {
        Console.WriteLine("No commits");
        return;
    }

    while (!string.IsNullOrEmpty(current) && current != "NONE")
    {
        string commitPath = Path.Combine(MinigitDir(), "commits", current);
        if (!File.Exists(commitPath)) break;

        string[] lines = File.ReadAllLines(commitPath);
        string parent = "";
        string timestamp = "";
        string message = "";

        foreach (string line in lines)
        {
            if (line.StartsWith("parent: ")) parent = line.Substring("parent: ".Length).Trim();
            else if (line.StartsWith("timestamp: ")) timestamp = line.Substring("timestamp: ".Length).Trim();
            else if (line.StartsWith("message: ")) message = line.Substring("message: ".Length).Trim();
        }

        Console.WriteLine($"commit {current}");
        Console.WriteLine($"Date: {timestamp}");
        Console.WriteLine($"Message: {message}");
        Console.WriteLine();

        current = (parent == "NONE") ? "" : parent;
    }
}

static void Status()
{
    string indexPath = Path.Combine(MinigitDir(), "index");
    string[] staged = File.Exists(indexPath)
        ? File.ReadAllLines(indexPath).Where(l => !string.IsNullOrEmpty(l)).ToArray()
        : Array.Empty<string>();

    Console.WriteLine("Staged files:");
    if (staged.Length == 0)
    {
        Console.WriteLine("(none)");
    }
    else
    {
        foreach (string f in staged)
            Console.WriteLine(f);
    }
}

static Dictionary<string, string> ParseCommitFiles(string[] lines)
{
    var files = new Dictionary<string, string>();
    bool inFiles = false;
    foreach (string line in lines)
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
                string name = line.Substring(0, spaceIdx);
                string hash = line.Substring(spaceIdx + 1);
                files[name] = hash;
            }
        }
    }
    return files;
}

static void Diff(string commit1, string commit2)
{
    string c1Path = Path.Combine(MinigitDir(), "commits", commit1);
    string c2Path = Path.Combine(MinigitDir(), "commits", commit2);

    if (!File.Exists(c1Path) || !File.Exists(c2Path))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    var files1 = ParseCommitFiles(File.ReadAllLines(c1Path));
    var files2 = ParseCommitFiles(File.ReadAllLines(c2Path));

    var allFiles = files1.Keys.Union(files2.Keys).OrderBy(f => f);
    foreach (string f in allFiles)
    {
        bool in1 = files1.ContainsKey(f);
        bool in2 = files2.ContainsKey(f);

        if (in1 && !in2)
            Console.WriteLine($"Removed: {f}");
        else if (!in1 && in2)
            Console.WriteLine($"Added: {f}");
        else if (files1[f] != files2[f])
            Console.WriteLine($"Modified: {f}");
    }
}

static void Checkout(string commitHash)
{
    string commitPath = Path.Combine(MinigitDir(), "commits", commitHash);
    if (!File.Exists(commitPath))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    string[] lines = File.ReadAllLines(commitPath);
    var files = ParseCommitFiles(lines);

    foreach (var kvp in files)
    {
        string blobPath = Path.Combine(MinigitDir(), "objects", kvp.Value);
        byte[] content = File.ReadAllBytes(blobPath);
        string dir = Path.GetDirectoryName(kvp.Key)!;
        if (!string.IsNullOrEmpty(dir))
            Directory.CreateDirectory(dir);
        File.WriteAllBytes(kvp.Key, content);
    }

    File.WriteAllText(Path.Combine(MinigitDir(), "HEAD"), commitHash);
    File.WriteAllText(Path.Combine(MinigitDir(), "index"), "");

    Console.WriteLine($"Checked out {commitHash}");
}

static void Reset(string commitHash)
{
    string commitPath = Path.Combine(MinigitDir(), "commits", commitHash);
    if (!File.Exists(commitPath))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    File.WriteAllText(Path.Combine(MinigitDir(), "HEAD"), commitHash);
    File.WriteAllText(Path.Combine(MinigitDir(), "index"), "");

    Console.WriteLine($"Reset to {commitHash}");
}

static void Rm(string filename)
{
    string indexPath = Path.Combine(MinigitDir(), "index");
    string[] existing = File.Exists(indexPath)
        ? File.ReadAllLines(indexPath).Where(l => !string.IsNullOrEmpty(l)).ToArray()
        : Array.Empty<string>();

    if (!existing.Contains(filename))
    {
        Console.WriteLine("File not in index");
        Environment.Exit(1);
    }

    string[] updated = existing.Where(f => f != filename).ToArray();
    File.WriteAllText(indexPath, updated.Length > 0 ? string.Join("\n", updated) + "\n" : "");
}

static void Show(string commitHash)
{
    string commitPath = Path.Combine(MinigitDir(), "commits", commitHash);
    if (!File.Exists(commitPath))
    {
        Console.WriteLine("Invalid commit");
        Environment.Exit(1);
    }

    string[] lines = File.ReadAllLines(commitPath);
    string timestamp = "";
    string message = "";

    foreach (string line in lines)
    {
        if (line.StartsWith("timestamp: ")) timestamp = line.Substring("timestamp: ".Length).Trim();
        else if (line.StartsWith("message: ")) message = line.Substring("message: ".Length).Trim();
    }

    var files = ParseCommitFiles(lines);

    Console.WriteLine($"commit {commitHash}");
    Console.WriteLine($"Date: {timestamp}");
    Console.WriteLine($"Message: {message}");
    Console.WriteLine("Files:");
    foreach (var kvp in files.OrderBy(k => k.Key))
        Console.WriteLine($"  {kvp.Key} {kvp.Value}");
}
