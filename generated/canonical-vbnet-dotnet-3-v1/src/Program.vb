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
