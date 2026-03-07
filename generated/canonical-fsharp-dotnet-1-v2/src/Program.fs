module Minigit

open System
open System.IO

let miniHash (data: byte[]) : string =
    let mutable h = 1469598103934665603UL
    for b in data do
        h <- h ^^^ uint64 b
        h <- h * 1099511628211UL  // wraps naturally in uint64
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

let cmdAdd (filename: string) =
    if not (File.Exists(filename)) then
        printfn "File not found"
        1
    else
        let data = File.ReadAllBytes(filename)
        let hash = miniHash data
        let blobPath = Path.Combine(objectsDir, hash)
        File.WriteAllBytes(blobPath, data)
        let staged =
            if File.Exists(indexFile) then
                File.ReadAllLines(indexFile) |> Array.filter (fun s -> s <> "") |> Array.toList
            else []
        if not (List.contains filename staged) then
            File.AppendAllText(indexFile, filename + "\n")
        0

let cmdCommit (message: string) =
    let staged =
        if File.Exists(indexFile) then
            File.ReadAllLines(indexFile) |> Array.filter (fun s -> s <> "") |> Array.toList
        else []
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
        // Build file entries: filename -> blobhash
        // We need current blob for each staged file
        // Re-read objects to find blobs; simplest: re-hash each staged file
        // But we store blob at add time; we need to look up by filename.
        // Simplest approach: re-read the file and compute hash (or store mapping).
        // Since spec says "files in index are staged filenames", we need their blob hashes.
        // The blob was stored at add time. We need to find which blob corresponds to each file.
        // Re-hash the file content to find the blob hash (same content = same hash).
        // But what if the file changed after add? Spec doesn't address this edge case.
        // We'll re-hash the current object by checking what we stored at add time.
        // Actually, git stores the blob at add time and the index maps filename->hash.
        // Let's store the mapping: we'll use a simple approach where index stores "filename blobhash".
        // But the current index only stores filenames. Let me re-read spec...
        // Spec says: "index: staged filenames (one per line)"
        // So index only has filenames. We need to find the blob for each.
        // We'll re-hash the file to get the blob hash (same as what was stored at add time).
        // This matches what was stored since we store blob at objects/<hash>.
        let fileEntries =
            staged
            |> List.sort
            |> List.map (fun fname ->
                let data = File.ReadAllBytes(fname)
                let hash = miniHash data
                (fname, hash))
        let filesSection =
            fileEntries
            |> List.map (fun (fname, hash) -> sprintf "%s %s" fname hash)
            |> String.concat "\n"
        let commitContent =
            sprintf "parent: %s\ntimestamp: %d\nmessage: %s\nfiles:\n%s\n"
                parent timestamp message filesSection
        let commitBytes = Text.Encoding.UTF8.GetBytes(commitContent)
        let commitHash = miniHash commitBytes
        let commitPath = Path.Combine(commitsDir, commitHash)
        File.WriteAllText(commitPath, commitContent)
        File.WriteAllText(headFile, commitHash)
        File.WriteAllText(indexFile, "")
        printfn "Committed %s" commitHash
        0

let cmdLog () =
    if not (File.Exists(headFile)) then
        printfn "No commits"
        0
    else
        let head = File.ReadAllText(headFile).Trim()
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
                    let parentLine = lines |> Array.tryFind (fun l -> l.StartsWith("parent: "))
                    let timestampLine = lines |> Array.tryFind (fun l -> l.StartsWith("timestamp: "))
                    let messageLine = lines |> Array.tryFind (fun l -> l.StartsWith("message: "))
                    let timestamp =
                        match timestampLine with
                        | Some l -> l.Substring("timestamp: ".Length).Trim()
                        | None -> ""
                    let msg =
                        match messageLine with
                        | Some l -> l.Substring("message: ".Length).Trim()
                        | None -> ""
                    printfn "commit %s" current
                    printfn "Date: %s" timestamp
                    printfn "Message: %s" msg
                    printfn ""
                    match parentLine with
                    | Some l ->
                        let p = l.Substring("parent: ".Length).Trim()
                        if p = "NONE" then stop <- true
                        else current <- p
                    | None -> stop <- true
            0

let cmdStatus () =
    let staged =
        if File.Exists(indexFile) then
            File.ReadAllLines(indexFile) |> Array.filter (fun s -> s <> "") |> Array.toList
        else []
    printfn "Staged files:"
    if staged.IsEmpty then
        printfn "(none)"
    else
        for f in staged do
            printfn "%s" f
    0

// Parse files section from a commit file. Returns list of (filename, blobhash).
let parseCommitFiles (commitPath: string) : (string * string) list =
    let lines = File.ReadAllLines(commitPath)
    let filesIdx = lines |> Array.tryFindIndex (fun l -> l = "files:")
    match filesIdx with
    | None -> []
    | Some idx ->
        lines
        |> Array.skip (idx + 1)
        |> Array.filter (fun l -> l <> "")
        |> Array.toList
        |> List.choose (fun l ->
            let parts = l.Split(' ')
            if parts.Length >= 2 then Some (parts.[0], parts.[1])
            else None)

let cmdDiff (hash1: string) (hash2: string) =
    let path1 = Path.Combine(commitsDir, hash1)
    let path2 = Path.Combine(commitsDir, hash2)
    if not (File.Exists(path1)) || not (File.Exists(path2)) then
        printfn "Invalid commit"
        1
    else
        let files1 = parseCommitFiles path1 |> Map.ofList
        let files2 = parseCommitFiles path2 |> Map.ofList
        let allFiles =
            Set.union (files1 |> Map.toSeq |> Seq.map fst |> Set.ofSeq)
                      (files2 |> Map.toSeq |> Seq.map fst |> Set.ofSeq)
            |> Set.toList |> List.sort
        for f in allFiles do
            match Map.tryFind f files1, Map.tryFind f files2 with
            | None, Some _ -> printfn "Added: %s" f
            | Some _, None -> printfn "Removed: %s" f
            | Some h1, Some h2 when h1 <> h2 -> printfn "Modified: %s" f
            | _ -> ()
        0

let cmdCheckout (hash: string) =
    let commitPath = Path.Combine(commitsDir, hash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        let files = parseCommitFiles commitPath
        for (fname, blobHash) in files do
            let blobPath = Path.Combine(objectsDir, blobHash)
            let data = File.ReadAllBytes(blobPath)
            let dir = Path.GetDirectoryName(fname)
            if dir <> "" && dir <> null then
                Directory.CreateDirectory(dir) |> ignore
            File.WriteAllBytes(fname, data)
        File.WriteAllText(headFile, hash)
        File.WriteAllText(indexFile, "")
        printfn "Checked out %s" hash
        0

let cmdReset (hash: string) =
    let commitPath = Path.Combine(commitsDir, hash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        File.WriteAllText(headFile, hash)
        File.WriteAllText(indexFile, "")
        printfn "Reset to %s" hash
        0

let cmdRm (filename: string) =
    let staged =
        if File.Exists(indexFile) then
            File.ReadAllLines(indexFile) |> Array.filter (fun s -> s <> "") |> Array.toList
        else []
    if not (List.contains filename staged) then
        printfn "File not in index"
        1
    else
        let updated = staged |> List.filter (fun s -> s <> filename)
        File.WriteAllText(indexFile, String.concat "\n" updated + (if updated.IsEmpty then "" else "\n"))
        0

let cmdShow (hash: string) =
    let commitPath = Path.Combine(commitsDir, hash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        let lines = File.ReadAllLines(commitPath)
        let timestampLine = lines |> Array.tryFind (fun l -> l.StartsWith("timestamp: "))
        let messageLine = lines |> Array.tryFind (fun l -> l.StartsWith("message: "))
        let timestamp =
            match timestampLine with
            | Some l -> l.Substring("timestamp: ".Length).Trim()
            | None -> ""
        let msg =
            match messageLine with
            | Some l -> l.Substring("message: ".Length).Trim()
            | None -> ""
        printfn "commit %s" hash
        printfn "Date: %s" timestamp
        printfn "Message: %s" msg
        printfn "Files:"
        let files = parseCommitFiles commitPath |> List.sortBy fst
        for (fname, blobHash) in files do
            printfn "  %s %s" fname blobHash
        0

[<EntryPoint>]
let main argv =
    match argv with
    | [| "init" |] -> cmdInit ()
    | [| "add"; filename |] -> cmdAdd filename
    | [| "commit"; "-m"; message |] -> cmdCommit message
    | [| "log" |] -> cmdLog ()
    | [| "status" |] -> cmdStatus ()
    | [| "diff"; hash1; hash2 |] -> cmdDiff hash1 hash2
    | [| "checkout"; hash |] -> cmdCheckout hash
    | [| "reset"; hash |] -> cmdReset hash
    | [| "rm"; filename |] -> cmdRm filename
    | [| "show"; hash |] -> cmdShow hash
    | _ ->
        eprintfn "Usage: minigit <init|add|commit|log|status|diff|checkout|reset|rm|show>"
        1
