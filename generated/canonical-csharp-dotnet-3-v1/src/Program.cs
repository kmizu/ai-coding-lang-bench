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

    // Build files section: sorted filenames with their blob hashes
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
