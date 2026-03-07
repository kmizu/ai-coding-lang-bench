Imports System
Imports System.IO
Imports System.Text

Module Program
    Function MiniHash(data As Byte()) As String
        Dim h As ULong = 1469598103934665603UL
        For Each b As Byte In data
            h = h Xor CULng(b)
            h = h * 1099511628211UL
        Next
        Return h.ToString("x16")
    End Function

    Sub Main(args As String())
        If args.Length = 0 Then
            Console.Error.WriteLine("Usage: minigit <command>")
            Environment.Exit(1)
        End If

        Dim cmd As String = args(0)
        Select Case cmd
            Case "init"
                DoInit()
            Case "add"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit add <file>")
                    Environment.Exit(1)
                End If
                DoAdd(args(1))
            Case "commit"
                If args.Length < 3 OrElse args(1) <> "-m" Then
                    Console.Error.WriteLine("Usage: minigit commit -m <message>")
                    Environment.Exit(1)
                End If
                DoCommit(args(2))
            Case "log"
                DoLog()
            Case "status"
                DoStatus()
            Case "diff"
                If args.Length < 3 Then
                    Console.Error.WriteLine("Usage: minigit diff <commit1> <commit2>")
                    Environment.Exit(1)
                End If
                DoDiff(args(1), args(2))
            Case "checkout"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit checkout <commit_hash>")
                    Environment.Exit(1)
                End If
                DoCheckout(args(1))
            Case "reset"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit reset <commit_hash>")
                    Environment.Exit(1)
                End If
                DoReset(args(1))
            Case "rm"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit rm <file>")
                    Environment.Exit(1)
                End If
                DoRm(args(1))
            Case "show"
                If args.Length < 2 Then
                    Console.Error.WriteLine("Usage: minigit show <commit_hash>")
                    Environment.Exit(1)
                End If
                DoShow(args(1))
            Case Else
                Console.Error.WriteLine("Unknown command: " & cmd)
                Environment.Exit(1)
        End Select
    End Sub

    Sub DoInit()
        Dim minigitDir As String = Path.Combine(Directory.GetCurrentDirectory(), ".minigit")
        If Directory.Exists(minigitDir) Then
            Console.WriteLine("Repository already initialized")
            Environment.Exit(0)
        End If
        Directory.CreateDirectory(Path.Combine(minigitDir, "objects"))
        Directory.CreateDirectory(Path.Combine(minigitDir, "commits"))
        File.WriteAllText(Path.Combine(minigitDir, "index"), "")
        File.WriteAllText(Path.Combine(minigitDir, "HEAD"), "")
    End Sub

    Sub DoAdd(filename As String)
        If Not File.Exists(filename) Then
            Console.WriteLine("File not found")
            Environment.Exit(1)
        End If

        Dim data As Byte() = File.ReadAllBytes(filename)
        Dim hash As String = MiniHash(data)

        Dim objectPath As String = Path.Combine(".minigit", "objects", hash)
        File.WriteAllBytes(objectPath, data)

        Dim indexPath As String = Path.Combine(".minigit", "index")
        Dim lines As New System.Collections.Generic.List(Of String)
        If File.Exists(indexPath) Then
            For Each line As String In File.ReadAllLines(indexPath)
                If line.Trim() <> "" Then
                    lines.Add(line)
                End If
            Next
        End If

        If Not lines.Contains(filename) Then
            lines.Add(filename)
            File.WriteAllLines(indexPath, lines)
        End If
    End Sub

    Sub DoCommit(message As String)
        Dim indexPath As String = Path.Combine(".minigit", "index")
        Dim headPath As String = Path.Combine(".minigit", "HEAD")

        Dim stagedFiles As New System.Collections.Generic.List(Of String)
        If File.Exists(indexPath) Then
            For Each line As String In File.ReadAllLines(indexPath)
                If line.Trim() <> "" Then
                    stagedFiles.Add(line.Trim())
                End If
            Next
        End If

        If stagedFiles.Count = 0 Then
            Console.WriteLine("Nothing to commit")
            Environment.Exit(1)
        End If

        Dim parent As String = "NONE"
        If File.Exists(headPath) Then
            Dim headContent As String = File.ReadAllText(headPath).Trim()
            If headContent <> "" Then
                parent = headContent
            End If
        End If

        Dim timestamp As Long = DateTimeOffset.UtcNow.ToUnixTimeSeconds()

        stagedFiles.Sort(StringComparer.Ordinal)

        Dim sb As New StringBuilder()
        sb.AppendLine("parent: " & parent)
        sb.AppendLine("timestamp: " & timestamp.ToString())
        sb.AppendLine("message: " & message)
        sb.AppendLine("files:")
        For Each f As String In stagedFiles
            Dim blobHash As String = GetBlobHash(f)
            sb.AppendLine(f & " " & blobHash)
        Next

        Dim commitContent As String = sb.ToString()
        Dim commitBytes As Byte() = Encoding.UTF8.GetBytes(commitContent)
        Dim commitHash As String = MiniHash(commitBytes)

        File.WriteAllText(Path.Combine(".minigit", "commits", commitHash), commitContent)
        File.WriteAllText(headPath, commitHash)
        File.WriteAllText(indexPath, "")

        Console.WriteLine("Committed " & commitHash)
    End Sub

    Function GetBlobHash(filename As String) As String
        Dim data As Byte() = File.ReadAllBytes(filename)
        Return MiniHash(data)
    End Function

    Function ParseCommitFiles(commitPath As String) As System.Collections.Generic.Dictionary(Of String, String)
        Dim result As New System.Collections.Generic.Dictionary(Of String, String)()
        Dim inFiles As Boolean = False
        For Each line As String In File.ReadAllLines(commitPath)
            If line = "files:" Then
                inFiles = True
            ElseIf inFiles Then
                Dim parts As String() = line.Split(" "c)
                If parts.Length >= 2 Then
                    result(parts(0)) = parts(1)
                End If
            End If
        Next
        Return result
    End Function

    Sub DoStatus()
        Dim indexPath As String = Path.Combine(".minigit", "index")
        Dim staged As New System.Collections.Generic.List(Of String)()
        If File.Exists(indexPath) Then
            For Each line As String In File.ReadAllLines(indexPath)
                If line.Trim() <> "" Then
                    staged.Add(line.Trim())
                End If
            Next
        End If
        Console.WriteLine("Staged files:")
        If staged.Count = 0 Then
            Console.WriteLine("(none)")
        Else
            For Each f As String In staged
                Console.WriteLine(f)
            Next
        End If
    End Sub

    Sub DoDiff(commit1 As String, commit2 As String)
        Dim path1 As String = Path.Combine(".minigit", "commits", commit1)
        Dim path2 As String = Path.Combine(".minigit", "commits", commit2)
        If Not File.Exists(path1) OrElse Not File.Exists(path2) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        Dim files1 As System.Collections.Generic.Dictionary(Of String, String) = ParseCommitFiles(path1)
        Dim files2 As System.Collections.Generic.Dictionary(Of String, String) = ParseCommitFiles(path2)
        Dim allFiles As New System.Collections.Generic.HashSet(Of String)()
        For Each k As String In files1.Keys
            allFiles.Add(k)
        Next
        For Each k As String In files2.Keys
            allFiles.Add(k)
        Next
        Dim sorted As New System.Collections.Generic.List(Of String)(allFiles)
        sorted.Sort(StringComparer.Ordinal)
        For Each f As String In sorted
            Dim inA As Boolean = files1.ContainsKey(f)
            Dim inB As Boolean = files2.ContainsKey(f)
            If inA AndAlso inB Then
                If files1(f) <> files2(f) Then
                    Console.WriteLine("Modified: " & f)
                End If
            ElseIf Not inA AndAlso inB Then
                Console.WriteLine("Added: " & f)
            ElseIf inA AndAlso Not inB Then
                Console.WriteLine("Removed: " & f)
            End If
        Next
    End Sub

    Sub DoCheckout(commitHash As String)
        Dim commitPath As String = Path.Combine(".minigit", "commits", commitHash)
        If Not File.Exists(commitPath) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        Dim files As System.Collections.Generic.Dictionary(Of String, String) = ParseCommitFiles(commitPath)
        For Each kvp As System.Collections.Generic.KeyValuePair(Of String, String) In files
            Dim blobPath As String = Path.Combine(".minigit", "objects", kvp.Value)
            Dim content As Byte() = File.ReadAllBytes(blobPath)
            File.WriteAllBytes(kvp.Key, content)
        Next
        File.WriteAllText(Path.Combine(".minigit", "HEAD"), commitHash)
        File.WriteAllText(Path.Combine(".minigit", "index"), "")
        Console.WriteLine("Checked out " & commitHash)
    End Sub

    Sub DoReset(commitHash As String)
        Dim commitPath As String = Path.Combine(".minigit", "commits", commitHash)
        If Not File.Exists(commitPath) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        File.WriteAllText(Path.Combine(".minigit", "HEAD"), commitHash)
        File.WriteAllText(Path.Combine(".minigit", "index"), "")
        Console.WriteLine("Reset to " & commitHash)
    End Sub

    Sub DoRm(filename As String)
        Dim indexPath As String = Path.Combine(".minigit", "index")
        Dim lines As New System.Collections.Generic.List(Of String)()
        If File.Exists(indexPath) Then
            For Each line As String In File.ReadAllLines(indexPath)
                If line.Trim() <> "" Then
                    lines.Add(line.Trim())
                End If
            Next
        End If
        If Not lines.Contains(filename) Then
            Console.WriteLine("File not in index")
            Environment.Exit(1)
        End If
        lines.Remove(filename)
        File.WriteAllLines(indexPath, lines)
    End Sub

    Sub DoShow(commitHash As String)
        Dim commitPath As String = Path.Combine(".minigit", "commits", commitHash)
        If Not File.Exists(commitPath) Then
            Console.WriteLine("Invalid commit")
            Environment.Exit(1)
        End If
        Dim timestamp As String = ""
        Dim msg As String = ""
        Dim fileEntries As New System.Collections.Generic.List(Of String)()
        Dim inFiles As Boolean = False
        For Each line As String In File.ReadAllLines(commitPath)
            If line.StartsWith("timestamp: ") Then
                timestamp = line.Substring(11).Trim()
            ElseIf line.StartsWith("message: ") Then
                msg = line.Substring(9).Trim()
            ElseIf line = "files:" Then
                inFiles = True
            ElseIf inFiles AndAlso line.Trim() <> "" Then
                fileEntries.Add(line.Trim())
            End If
        Next
        fileEntries.Sort(StringComparer.Ordinal)
        Console.WriteLine("commit " & commitHash)
        Console.WriteLine("Date: " & timestamp)
        Console.WriteLine("Message: " & msg)
        Console.WriteLine("Files:")
        For Each entry As String In fileEntries
            Console.WriteLine("  " & entry)
        Next
    End Sub

    Sub DoLog()
        Dim headPath As String = Path.Combine(".minigit", "HEAD")
        If Not File.Exists(headPath) Then
            Console.WriteLine("No commits")
            Return
        End If

        Dim current As String = File.ReadAllText(headPath).Trim()
        If current = "" Then
            Console.WriteLine("No commits")
            Return
        End If

        While current <> "" AndAlso current <> "NONE"
            Dim commitPath As String = Path.Combine(".minigit", "commits", current)
            If Not File.Exists(commitPath) Then
                Exit While
            End If

            Dim lines As String() = File.ReadAllLines(commitPath)
            Dim parentHash As String = ""
            Dim timestamp As String = ""
            Dim msg As String = ""

            For Each line As String In lines
                If line.StartsWith("parent: ") Then
                    parentHash = line.Substring(8).Trim()
                ElseIf line.StartsWith("timestamp: ") Then
                    timestamp = line.Substring(11).Trim()
                ElseIf line.StartsWith("message: ") Then
                    msg = line.Substring(9).Trim()
                End If
            Next

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
End Module
