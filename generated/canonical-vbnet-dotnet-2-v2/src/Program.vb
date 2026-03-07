Imports System
Imports System.IO
Imports System.Text
Imports System.Collections.Generic

Module Program

    Function MiniHash(data As Byte()) As String
        Dim h As ULong = 1469598103934665603UL
        For Each b As Byte In data
            h = h Xor CULng(b)
            h = h * 1099511628211UL
        Next
        Return h.ToString("x16")
    End Function

    Function GetMinigitDir() As String
        Return Path.Combine(Directory.GetCurrentDirectory(), ".minigit")
    End Function

    ' Parse a commit file and return a Dictionary of filename -> blobhash
    ' Also outputs parent, timestamp, message via ByRef
    Function ParseCommit(commitPath As String, ByRef parent As String, ByRef timestamp As String, ByRef message As String) As Dictionary(Of String, String)
        Dim lines As String() = File.ReadAllLines(commitPath)
        Dim files As New Dictionary(Of String, String)
        parent = ""
        timestamp = ""
        message = ""
        Dim inFiles As Boolean = False
        For Each line As String In lines
            If inFiles Then
                If line.Trim() <> "" Then
                    Dim parts As String() = line.Split(" "c)
                    If parts.Length >= 2 Then
                        files(parts(0)) = parts(1)
                    End If
                End If
            ElseIf line.StartsWith("parent: ") Then
                parent = line.Substring(8).Trim()
            ElseIf line.StartsWith("timestamp: ") Then
                timestamp = line.Substring(11).Trim()
            ElseIf line.StartsWith("message: ") Then
                message = line.Substring(9).Trim()
            ElseIf line = "files:" Then
                inFiles = True
            End If
        Next
        Return files
    End Function

    Sub CmdInit()
        Dim dir As String = GetMinigitDir()
        If Directory.Exists(dir) Then
            Console.WriteLine("Repository already initialized")
            Return
        End If
        Directory.CreateDirectory(Path.Combine(dir, "objects"))
        Directory.CreateDirectory(Path.Combine(dir, "commits"))
        File.WriteAllText(Path.Combine(dir, "index"), "")
        File.WriteAllText(Path.Combine(dir, "HEAD"), "")
        Console.WriteLine("Initialized empty repository")
    End Sub

    Sub CmdAdd(filename As String)
        Dim dir As String = GetMinigitDir()
        If Not File.Exists(filename) Then
            Console.WriteLine("File not found")
            Environment.Exit(1)
        End If
        Dim data As Byte() = File.ReadAllBytes(filename)
        Dim hash As String = MiniHash(data)
        Dim objPath As String = Path.Combine(dir, "objects", hash)
        File.WriteAllBytes(objPath, data)
        Dim indexPath As String = Path.Combine(dir, "index")
        Dim lines As String() = File.ReadAllText(indexPath).Split(New Char() {vbLf(0), vbCr(0)}, StringSplitOptions.RemoveEmptyEntries)
        Dim found As Boolean = False
        For Each line As String In lines
            If line = filename Then
                found = True
                Exit For
            End If
        Next
        If Not found Then
            File.AppendAllText(indexPath, filename & vbLf)
        End If
    End Sub

    Sub CmdCommit(message As String)
        Dim dir As String = GetMinigitDir()
        Dim indexPath As String = Path.Combine(dir, "index")
        Dim indexContent As String = File.ReadAllText(indexPath)
        Dim files As String() = indexContent.Split(New Char() {vbLf(0), vbCr(0)}, StringSplitOptions.RemoveEmptyEntries)
        If files.Length = 0 Then
            Console.WriteLine("Nothing to commit")
            Environment.Exit(1)
        End If
        Array.Sort(files, StringComparer.Ordinal)
        Dim headPath As String = Path.Combine(dir, "HEAD")
        Dim parent As String = File.ReadAllText(headPath).Trim()
        If parent = "" Then parent = "NONE"
        Dim timestamp As Long = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        Dim sb As New StringBuilder()
        sb.AppendLine("parent: " & parent)
        sb.AppendLine("timestamp: " & timestamp.ToString())
        sb.AppendLine("message: " & message)
        sb.AppendLine("files:")
        For Each f As String In files
            Dim data As Byte() = File.ReadAllBytes(f)
            Dim blobHash As String = MiniHash(data)
            sb.AppendLine(f & " " & blobHash)
        Next
        Dim commitContent As String = sb.ToString()
        Dim commitHash As String = MiniHash(Encoding.UTF8.GetBytes(commitContent))
        File.WriteAllText(Path.Combine(dir, "commits", commitHash), commitContent)
        File.WriteAllText(headPath, commitHash)
        File.WriteAllText(indexPath, "")
        Console.WriteLine("Committed " & commitHash)
    End Sub

    Sub CmdStatus()
        Dim dir As String = GetMinigitDir()
        Dim indexPath As String = Path.Combine(dir, "index")
        Dim indexContent As String = File.ReadAllText(indexPath)
        Dim files As String() = indexContent.Split(New Char() {vbLf(0), vbCr(0)}, StringSplitOptions.RemoveEmptyEntries)
        Console.WriteLine("Staged files:")
        If files.Length = 0 Then
            Console.WriteLine("(none)")
        Else
            For Each f As String In files
                Console.WriteLine(f)
            Next
        End If
    End Sub

    Sub CmdLog()
        Dim dir As String = GetMinigitDir()
        Dim headPath As String = Path.Combine(dir, "HEAD")
        Dim current As String = File.ReadAllText(headPath).Trim()
        If current = "" Then
            Console.WriteLine("No commits")
            Return
        End If
        While current <> "" AndAlso current <> "NONE"
            Dim commitPath As String = Path.Combine(dir, "commits", current)
            If Not File.Exists(commitPath) Then Exit While
            Dim parentHash As String = ""
            Dim timestamp As String = ""
            Dim msg As String = ""
            ParseCommit(commitPath, parentHash, timestamp, msg)
            Console.WriteLine("commit " & current)
            Console.WriteLine("Date: " & timestamp)
            Console.WriteLine("Message: " & msg)
            Console.WriteLine()
            If parentHash = "NONE" OrElse parentHash = "" Then
                Exit While
            End If
            current = parentHash
        End While
    End Sub

    Sub CmdDiff(commit1 As String, commit2 As String)
        Dim dir As String = GetMinigitDir()
        Dim path1 As String = Path.Combine(dir, "commits", commit1)
        Dim path2 As String = Path.Combine(dir, "commits", commit2)
        If Not File.Exists(path1) OrElse Not File.Exists(path2) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        Dim p1 As String = "", t1 As String = "", m1 As String = ""
        Dim p2 As String = "", t2 As String = "", m2 As String = ""
        Dim files1 As Dictionary(Of String, String) = ParseCommit(path1, p1, t1, m1)
        Dim files2 As Dictionary(Of String, String) = ParseCommit(path2, p2, t2, m2)

        ' Collect all filenames
        Dim allFiles As New SortedSet(Of String)(StringComparer.Ordinal)
        For Each k As String In files1.Keys
            allFiles.Add(k)
        Next
        For Each k As String In files2.Keys
            allFiles.Add(k)
        Next

        For Each f As String In allFiles
            Dim inC1 As Boolean = files1.ContainsKey(f)
            Dim inC2 As Boolean = files2.ContainsKey(f)
            If inC1 AndAlso inC2 Then
                If files1(f) <> files2(f) Then
                    Console.WriteLine("Modified: " & f)
                End If
            ElseIf inC2 Then
                Console.WriteLine("Added: " & f)
            ElseIf inC1 Then
                Console.WriteLine("Removed: " & f)
            End If
        Next
    End Sub

    Sub CmdCheckout(commitHash As String)
        Dim dir As String = GetMinigitDir()
        Dim commitPath As String = Path.Combine(dir, "commits", commitHash)
        If Not File.Exists(commitPath) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        Dim parent As String = "", timestamp As String = "", message As String = ""
        Dim files As Dictionary(Of String, String) = ParseCommit(commitPath, parent, timestamp, message)
        For Each kvp As KeyValuePair(Of String, String) In files
            Dim blobPath As String = Path.Combine(dir, "objects", kvp.Value)
            Dim data As Byte() = File.ReadAllBytes(blobPath)
            Dim destDir As String = Path.GetDirectoryName(kvp.Key)
            If destDir IsNot Nothing AndAlso destDir <> "" Then
                Directory.CreateDirectory(destDir)
            End If
            File.WriteAllBytes(kvp.Key, data)
        Next
        File.WriteAllText(Path.Combine(dir, "HEAD"), commitHash)
        File.WriteAllText(Path.Combine(dir, "index"), "")
        Console.WriteLine("Checked out " & commitHash)
    End Sub

    Sub CmdReset(commitHash As String)
        Dim dir As String = GetMinigitDir()
        Dim commitPath As String = Path.Combine(dir, "commits", commitHash)
        If Not File.Exists(commitPath) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        File.WriteAllText(Path.Combine(dir, "HEAD"), commitHash)
        File.WriteAllText(Path.Combine(dir, "index"), "")
        Console.WriteLine("Reset to " & commitHash)
    End Sub

    Sub CmdRm(filename As String)
        Dim dir As String = GetMinigitDir()
        Dim indexPath As String = Path.Combine(dir, "index")
        Dim lines As String() = File.ReadAllText(indexPath).Split(New Char() {vbLf(0), vbCr(0)}, StringSplitOptions.RemoveEmptyEntries)
        Dim found As Boolean = False
        Dim newLines As New List(Of String)
        For Each line As String In lines
            If line = filename Then
                found = True
            Else
                newLines.Add(line)
            End If
        Next
        If Not found Then
            Console.WriteLine("File not in index")
            Environment.Exit(1)
        End If
        Dim content As New StringBuilder()
        For Each line As String In newLines
            content.AppendLine(line)
        Next
        File.WriteAllText(indexPath, content.ToString())
    End Sub

    Sub CmdShow(commitHash As String)
        Dim dir As String = GetMinigitDir()
        Dim commitPath As String = Path.Combine(dir, "commits", commitHash)
        If Not File.Exists(commitPath) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        Dim parent As String = "", timestamp As String = "", message As String = ""
        Dim files As Dictionary(Of String, String) = ParseCommit(commitPath, parent, timestamp, message)
        Console.WriteLine("commit " & commitHash)
        Console.WriteLine("Date: " & timestamp)
        Console.WriteLine("Message: " & message)
        Console.WriteLine("Files:")
        Dim sortedFiles As New SortedDictionary(Of String, String)(files, StringComparer.Ordinal)
        For Each kvp As KeyValuePair(Of String, String) In sortedFiles
            Console.WriteLine("  " & kvp.Key & " " & kvp.Value)
        Next
    End Sub

    Sub Main(args As String())
        If args.Length = 0 Then
            Console.Error.WriteLine("Usage: minigit <command>")
            Environment.Exit(1)
        End If

        Select Case args(0)
            Case "init"
                CmdInit()
            Case "add"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit add <file>")
                    Environment.Exit(1)
                End If
                CmdAdd(args(1))
            Case "commit"
                If args.Length < 3 OrElse args(1) <> "-m" Then
                    Console.Error.WriteLine("Usage: minigit commit -m ""<message>""")
                    Environment.Exit(1)
                End If
                CmdCommit(args(2))
            Case "status"
                CmdStatus()
            Case "log"
                CmdLog()
            Case "diff"
                If args.Length < 3 Then
                    Console.Error.WriteLine("Usage: minigit diff <commit1> <commit2>")
                    Environment.Exit(1)
                End If
                CmdDiff(args(1), args(2))
            Case "checkout"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit checkout <commit_hash>")
                    Environment.Exit(1)
                End If
                CmdCheckout(args(1))
            Case "reset"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit reset <commit_hash>")
                    Environment.Exit(1)
                End If
                CmdReset(args(1))
            Case "rm"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit rm <file>")
                    Environment.Exit(1)
                End If
                CmdRm(args(1))
            Case "show"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit show <commit_hash>")
                    Environment.Exit(1)
                End If
                CmdShow(args(1))
            Case Else
                Console.Error.WriteLine("Unknown command: " & args(0))
                Environment.Exit(1)
        End Select
    End Sub

End Module
