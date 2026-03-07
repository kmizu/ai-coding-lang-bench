module MiniGit

open System
open System.IO

// MiniHash: FNV-1a variant, 64-bit, 16-char hex output
let miniHash (data: byte[]) : string =
    let mutable h = 1469598103934665603UL
    for b in data do
        h <- h ^^^ uint64 b
        h <- h * 1099511628211UL
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
        if not (File.Exists(blobPath)) then
            File.WriteAllBytes(blobPath, data)
        // Append to index if not already present
        let staged =
            if File.Exists(indexFile) then
                File.ReadAllLines(indexFile) |> Array.filter (fun s -> s.Length > 0) |> Array.toList
            else []
        if not (List.contains file staged) then
            File.AppendAllText(indexFile, file + "\n")
        0

let cmdCommit (message: string) =
    let staged =
        if File.Exists(indexFile) then
            File.ReadAllLines(indexFile) |> Array.filter (fun s -> s.Length > 0)
        else [||]
    if staged.Length = 0 then
        printfn "Nothing to commit"
        1
    else
        let parent =
            if File.Exists(headFile) then
                let h = File.ReadAllText(headFile).Trim()
                if h.Length > 0 then h else "NONE"
            else "NONE"
        let timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        // Build file entries: need current blob hash for each staged file
        let fileEntries =
            staged
            |> Array.sort
            |> Array.map (fun f ->
                let data = File.ReadAllBytes(f)
                let hash = miniHash data
                sprintf "%s %s" f hash)
        let commitContent =
            sprintf "parent: %s\ntimestamp: %d\nmessage: %s\nfiles:\n%s\n"
                parent timestamp message (String.concat "\n" fileEntries)
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
        if head.Length = 0 then
            printfn "No commits"
            0
        else
            let mutable current = head
            let mutable first = true
            while current <> "NONE" && current.Length > 0 do
                let commitPath = Path.Combine(commitsDir, current)
                if not (File.Exists(commitPath)) then
                    current <- ""
                else
                    let lines = File.ReadAllLines(commitPath)
                    let getField (prefix: string) =
                        lines
                        |> Array.tryFind (fun l -> l.StartsWith(prefix))
                        |> Option.map (fun l -> l.Substring(prefix.Length))
                        |> Option.defaultValue ""
                    let parent = getField "parent: "
                    let timestamp = getField "timestamp: "
                    let message = getField "message: "
                    if not first then printfn ""
                    printfn "commit %s" current
                    printfn "Date: %s" timestamp
                    printfn "Message: %s" message
                    first <- false
                    current <- if parent = "NONE" then "" else parent
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
