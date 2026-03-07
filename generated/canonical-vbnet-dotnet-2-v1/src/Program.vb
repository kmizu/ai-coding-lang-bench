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

    Function GetMinigitDir() As String
        Return Path.Combine(Directory.GetCurrentDirectory(), ".minigit")
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
            Case "log"
                CmdLog()
            Case Else
                Console.Error.WriteLine("Unknown command: " & args(0))
                Environment.Exit(1)
        End Select
    End Sub

End Module
