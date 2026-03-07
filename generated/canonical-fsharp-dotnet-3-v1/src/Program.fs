module MiniGit

open System
open System.IO

// MiniHash: FNV-1a variant, 64-bit
let miniHash (data: byte[]) : string =
    let mutable h = 1469598103934665603UL
    for b in data do
        h <- h ^^^ uint64 b
        h <- h * 1099511628211UL  // wraps naturally at 2^64 with unchecked arithmetic
    sprintf "%016x" h

let repoDir = ".minigit"
let objectsDir = Path.Combine(repoDir, "objects")
let commitsDir = Path.Combine(repoDir, "commits")
let indexFile = Path.Combine(repoDir, "index")
let headFile = Path.Combine(repoDir, "HEAD")

let cmdInit () =
    if Directory.Exists(repoDir) then
        printfn "Repository already initialized"
    else
        Directory.CreateDirectory(repoDir) |> ignore
        Directory.CreateDirectory(objectsDir) |> ignore
        Directory.CreateDirectory(commitsDir) |> ignore
        File.WriteAllText(indexFile, "")
        File.WriteAllText(headFile, "")
    0

let cmdAdd (file: string) =
    if not (File.Exists(file)) then
        printfn "File not found"
        1
    else
        let data = File.ReadAllBytes(file)
        let hash = miniHash data
        let blobPath = Path.Combine(objectsDir, hash)
        File.WriteAllBytes(blobPath, data)
        // Append to index if not already present
        let existing =
            if File.Exists(indexFile) then
                File.ReadAllLines(indexFile) |> Array.toList
            else
                []
        if not (List.contains file existing) then
            File.AppendAllText(indexFile, file + "\n")
        0

let cmdCommit (message: string) =
    let staged =
        if File.Exists(indexFile) then
            File.ReadAllLines(indexFile)
            |> Array.filter (fun s -> s.Trim() <> "")
            |> Array.toList
        else
            []
    if staged.IsEmpty then
        printfn "Nothing to commit"
        1
    else
        let parent =
            if File.Exists(headFile) then
                let h = File.ReadAllText(headFile).Trim()
                if h = "" then "NONE" else h
            else "NONE"
        let timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        // Compute blob hashes for staged files, sorted
        let fileEntries =
            staged
            |> List.sort
            |> List.map (fun f ->
                let data = File.ReadAllBytes(f)
                let hash = miniHash data
                (f, hash))
        // Build commit content
        let sb = System.Text.StringBuilder()
        sb.AppendLine(sprintf "parent: %s" parent) |> ignore
        sb.AppendLine(sprintf "timestamp: %d" timestamp) |> ignore
        sb.AppendLine(sprintf "message: %s" message) |> ignore
        sb.AppendLine("files:") |> ignore
        for (f, h) in fileEntries do
            sb.AppendLine(sprintf "%s %s" f h) |> ignore
        let content = sb.ToString()
        let contentBytes = System.Text.Encoding.UTF8.GetBytes(content)
        let commitHash = miniHash contentBytes
        File.WriteAllText(Path.Combine(commitsDir, commitHash), content)
        File.WriteAllText(headFile, commitHash)
        File.WriteAllText(indexFile, "")
        printfn "Committed %s" commitHash
        0

let cmdLog () =
    let head =
        if File.Exists(headFile) then File.ReadAllText(headFile).Trim()
        else ""
    if head = "" then
        printfn "No commits"
        0
    else
        let mutable current = head
        let mutable stop = false
        while not stop do
            let commitPath = Path.Combine(commitsDir, current)
            if not (File.Exists(commitPath)) then
                stop <- true
            else
                let lines = File.ReadAllLines(commitPath)
                // Parse parent, timestamp, message
                let parentLine = lines |> Array.tryFind (fun l -> l.StartsWith("parent: "))
                let timestampLine = lines |> Array.tryFind (fun l -> l.StartsWith("timestamp: "))
                let messageLine = lines |> Array.tryFind (fun l -> l.StartsWith("message: "))
                let parent =
                    match parentLine with
                    | Some l -> l.Substring("parent: ".Length).Trim()
                    | None -> "NONE"
                let timestamp =
                    match timestampLine with
                    | Some l -> l.Substring("timestamp: ".Length).Trim()
                    | None -> ""
                let message =
                    match messageLine with
                    | Some l -> l.Substring("message: ".Length).Trim()
                    | None -> ""
                printfn "commit %s" current
                printfn "Date: %s" timestamp
                printfn "Message: %s" message
                printfn ""
                if parent = "NONE" || parent = "" then
                    stop <- true
                else
                    current <- parent
        0

[<EntryPoint>]
let main argv =
    match argv with
    | [| "init" |] -> cmdInit ()
    | [| "add"; file |] -> cmdAdd file
    | [| "commit"; "-m"; msg |] -> cmdCommit msg
    | [| "log" |] -> cmdLog ()
    | _ ->
        eprintfn "Usage: minigit <init|add|commit|log>"
        1
