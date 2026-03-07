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

[<EntryPoint>]
let main argv =
    match argv with
    | [| "init" |] -> cmdInit ()
    | [| "add"; filename |] -> cmdAdd filename
    | [| "commit"; "-m"; message |] -> cmdCommit message
    | [| "log" |] -> cmdLog ()
    | _ ->
        eprintfn "Usage: minigit <init|add|commit|log>"
        1
