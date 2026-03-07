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

    // Build file entries: filename -> blobhash
    var fileEntries = new List<(string name, string hash)>();
    foreach (var fname in files)
    {
        // Read the blob hash from objects by re-hashing the staged object
        // The blob was stored at .minigit/objects/<hash> when added
        // We need to find the hash for the staged file
        // Re-read from objects: we stored by hash, so we need to track name->hash
        // Actually, re-compute from the current file or look up from stored blob
        // The spec says files in index are staged; we stored the blob at add time
        // We need the hash for each file - re-read current file and hash it
        // (same as what was stored)
        byte[] content = File.ReadAllBytes(fname);
        string hash = ComputeHash(content);
        fileEntries.Add((fname, hash));
    }

    // Sort lexicographically by filename
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
