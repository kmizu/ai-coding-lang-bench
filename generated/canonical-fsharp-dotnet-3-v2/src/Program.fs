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

let readIndex () =
    if File.Exists(indexFile) then
        File.ReadAllLines(indexFile)
        |> Array.filter (fun s -> s.Trim() <> "")
        |> Array.toList
    else
        []

let readHead () =
    if File.Exists(headFile) then File.ReadAllText(headFile).Trim()
    else ""

// Parse commit file into (parent, timestamp, message, files list)
let parseCommit (lines: string[]) =
    let parent =
        lines |> Array.tryFind (fun l -> l.StartsWith("parent: "))
        |> Option.map (fun l -> l.Substring("parent: ".Length).Trim())
        |> Option.defaultValue "NONE"
    let timestamp =
        lines |> Array.tryFind (fun l -> l.StartsWith("timestamp: "))
        |> Option.map (fun l -> l.Substring("timestamp: ".Length).Trim())
        |> Option.defaultValue ""
    let message =
        lines |> Array.tryFind (fun l -> l.StartsWith("message: "))
        |> Option.map (fun l -> l.Substring("message: ".Length).Trim())
        |> Option.defaultValue ""
    let filesIdx =
        lines |> Array.tryFindIndex (fun l -> l.Trim() = "files:")
    let files =
        match filesIdx with
        | None -> []
        | Some idx ->
            lines
            |> Array.skip (idx + 1)
            |> Array.filter (fun l -> l.Trim() <> "")
            |> Array.map (fun l ->
                let parts = l.Trim().Split(' ')
                if parts.Length >= 2 then (parts.[0], parts.[1])
                else (l.Trim(), ""))
            |> Array.toList
    (parent, timestamp, message, files)

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
        let existing = readIndex ()
        if not (List.contains file existing) then
            File.AppendAllText(indexFile, file + "\n")
        0

let cmdCommit (message: string) =
    let staged = readIndex ()
    if staged.IsEmpty then
        printfn "Nothing to commit"
        1
    else
        let parent =
            let h = readHead ()
            if h = "" then "NONE" else h
        let timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        let fileEntries =
            staged
            |> List.sort
            |> List.map (fun f ->
                let data = File.ReadAllBytes(f)
                let hash = miniHash data
                (f, hash))
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

let cmdStatus () =
    let staged = readIndex ()
    printfn "Staged files:"
    if staged.IsEmpty then
        printfn "(none)"
    else
        for f in staged do
            printfn "%s" f
    0

let cmdLog () =
    let head = readHead ()
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
                let (parent, timestamp, message, _) = parseCommit lines
                printfn "commit %s" current
                printfn "Date: %s" timestamp
                printfn "Message: %s" message
                printfn ""
                if parent = "NONE" || parent = "" then
                    stop <- true
                else
                    current <- parent
        0

let cmdDiff (commit1: string) (commit2: string) =
    let path1 = Path.Combine(commitsDir, commit1)
    let path2 = Path.Combine(commitsDir, commit2)
    if not (File.Exists(path1)) || not (File.Exists(path2)) then
        printfn "Invalid commit"
        1
    else
        let (_, _, _, files1) = parseCommit (File.ReadAllLines(path1))
        let (_, _, _, files2) = parseCommit (File.ReadAllLines(path2))
        let map1 = Map.ofList files1
        let map2 = Map.ofList files2
        let allFiles =
            (files1 |> List.map fst) @ (files2 |> List.map fst)
            |> List.distinct
            |> List.sort
        for f in allFiles do
            match Map.tryFind f map1, Map.tryFind f map2 with
            | None, Some _ -> printfn "Added: %s" f
            | Some _, None -> printfn "Removed: %s" f
            | Some h1, Some h2 when h1 <> h2 -> printfn "Modified: %s" f
            | _ -> ()
        0

let cmdCheckout (commitHash: string) =
    let commitPath = Path.Combine(commitsDir, commitHash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        let lines = File.ReadAllLines(commitPath)
        let (_, _, _, files) = parseCommit lines
        for (filename, blobHash) in files do
            let blobPath = Path.Combine(objectsDir, blobHash)
            let content = File.ReadAllBytes(blobPath)
            File.WriteAllBytes(filename, content)
        File.WriteAllText(headFile, commitHash)
        File.WriteAllText(indexFile, "")
        printfn "Checked out %s" commitHash
        0

let cmdReset (commitHash: string) =
    let commitPath = Path.Combine(commitsDir, commitHash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        File.WriteAllText(headFile, commitHash)
        File.WriteAllText(indexFile, "")
        printfn "Reset to %s" commitHash
        0

let cmdRm (file: string) =
    let existing = readIndex ()
    if not (List.contains file existing) then
        printfn "File not in index"
        1
    else
        let updated = existing |> List.filter (fun f -> f <> file)
        let content = updated |> List.map (fun f -> f + "\n") |> String.concat ""
        File.WriteAllText(indexFile, content)
        0

let cmdShow (commitHash: string) =
    let commitPath = Path.Combine(commitsDir, commitHash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        let lines = File.ReadAllLines(commitPath)
        let (_, timestamp, message, files) = parseCommit lines
        printfn "commit %s" commitHash
        printfn "Date: %s" timestamp
        printfn "Message: %s" message
        printfn "Files:"
        for (f, h) in files |> List.sortBy fst do
            printfn "  %s %s" f h
        0

[<EntryPoint>]
let main argv =
    match argv with
    | [| "init" |] -> cmdInit ()
    | [| "add"; file |] -> cmdAdd file
    | [| "commit"; "-m"; msg |] -> cmdCommit msg
    | [| "status" |] -> cmdStatus ()
    | [| "log" |] -> cmdLog ()
    | [| "diff"; c1; c2 |] -> cmdDiff c1 c2
    | [| "checkout"; hash |] -> cmdCheckout hash
    | [| "reset"; hash |] -> cmdReset hash
    | [| "rm"; file |] -> cmdRm file
    | [| "show"; hash |] -> cmdShow hash
    | _ ->
        eprintfn "Usage: minigit <init|add|commit|status|log|diff|checkout|reset|rm|show>"
        1
