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

let cmdStatus () =
    let staged =
        if File.Exists(indexFile) then
            File.ReadAllLines(indexFile) |> Array.filter (fun s -> s.Length > 0)
        else [||]
    printfn "Staged files:"
    if staged.Length = 0 then
        printfn "(none)"
    else
        for f in staged do
            printfn "%s" f
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

// Parse a commit file's files section into a map of filename -> blobhash
let parseCommitFiles (commitPath: string) : Map<string, string> =
    let lines = File.ReadAllLines(commitPath)
    let filesIdx = lines |> Array.tryFindIndex (fun l -> l = "files:")
    match filesIdx with
    | None -> Map.empty
    | Some idx ->
        lines
        |> Array.skip (idx + 1)
        |> Array.filter (fun l -> l.Length > 0)
        |> Array.choose (fun l ->
            let parts = l.Split(' ')
            if parts.Length >= 2 then Some (parts.[0], parts.[1])
            else None)
        |> Map.ofArray

let cmdDiff (commit1: string) (commit2: string) =
    let path1 = Path.Combine(commitsDir, commit1)
    let path2 = Path.Combine(commitsDir, commit2)
    if not (File.Exists(path1)) || not (File.Exists(path2)) then
        printfn "Invalid commit"
        1
    else
        let files1 = parseCommitFiles path1
        let files2 = parseCommitFiles path2
        let allFiles =
            Set.union (files1 |> Map.toSeq |> Seq.map fst |> Set.ofSeq)
                      (files2 |> Map.toSeq |> Seq.map fst |> Set.ofSeq)
            |> Set.toArray
            |> Array.sort
        for f in allFiles do
            let inC1 = Map.containsKey f files1
            let inC2 = Map.containsKey f files2
            if not inC1 && inC2 then
                printfn "Added: %s" f
            elif inC1 && not inC2 then
                printfn "Removed: %s" f
            elif inC1 && inC2 && files1.[f] <> files2.[f] then
                printfn "Modified: %s" f
        0

let cmdCheckout (commitHash: string) =
    let commitPath = Path.Combine(commitsDir, commitHash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        let files = parseCommitFiles commitPath
        for (filename, blobHash) in files |> Map.toSeq do
            let blobPath = Path.Combine(objectsDir, blobHash)
            let data = File.ReadAllBytes(blobPath)
            File.WriteAllBytes(filename, data)
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
    let staged =
        if File.Exists(indexFile) then
            File.ReadAllLines(indexFile) |> Array.filter (fun s -> s.Length > 0)
        else [||]
    if not (Array.contains file staged) then
        printfn "File not in index"
        1
    else
        let updated = staged |> Array.filter (fun f -> f <> file)
        File.WriteAllText(indexFile, String.concat "\n" updated + (if updated.Length > 0 then "\n" else ""))
        0

let cmdShow (commitHash: string) =
    let commitPath = Path.Combine(commitsDir, commitHash)
    if not (File.Exists(commitPath)) then
        printfn "Invalid commit"
        1
    else
        let lines = File.ReadAllLines(commitPath)
        let getField (prefix: string) =
            lines
            |> Array.tryFind (fun l -> l.StartsWith(prefix))
            |> Option.map (fun l -> l.Substring(prefix.Length))
            |> Option.defaultValue ""
        let timestamp = getField "timestamp: "
        let message = getField "message: "
        let files = parseCommitFiles commitPath
        printfn "commit %s" commitHash
        printfn "Date: %s" timestamp
        printfn "Message: %s" message
        printfn "Files:"
        for (filename, blobHash) in files |> Map.toSeq |> Seq.sortBy fst do
            printfn "  %s %s" filename blobHash
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
