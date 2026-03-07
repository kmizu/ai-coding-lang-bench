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
