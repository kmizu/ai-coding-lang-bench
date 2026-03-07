Imports System
Imports System.IO
Imports System.Numerics
Imports System.Text

Module Program

    Function MiniHash(data As Byte()) As String
        Dim TWO64 As BigInteger = BigInteger.Pow(2, 64)
        Dim h As BigInteger = New BigInteger(1469598103934665603UL)
        Dim mult As BigInteger = New BigInteger(1099511628211UL)

        For Each b As Byte In data
            h = h Xor New BigInteger(CInt(b))
            h = BigInteger.Remainder(h * mult, TWO64)
        Next

        Return h.ToString("x").PadLeft(16, "0"c)
    End Function

    Sub CmdInit()
        If Directory.Exists(".minigit") Then
            Console.WriteLine("Repository already initialized")
            Return
        End If
        Directory.CreateDirectory(Path.Combine(".minigit", "objects"))
        Directory.CreateDirectory(Path.Combine(".minigit", "commits"))
        File.WriteAllText(Path.Combine(".minigit", "index"), "")
        File.WriteAllText(Path.Combine(".minigit", "HEAD"), "")
    End Sub

    Sub CmdAdd(filename As String)
        If Not File.Exists(filename) Then
            Console.WriteLine("File not found")
            Environment.Exit(1)
        End If

        Dim data As Byte() = File.ReadAllBytes(filename)
        Dim hash As String = MiniHash(data)

        File.WriteAllBytes(Path.Combine(".minigit", "objects", hash), data)

        Dim indexPath As String = Path.Combine(".minigit", "index")
        Dim lines As New List(Of String)
        If File.Exists(indexPath) Then
            For Each line As String In File.ReadAllLines(indexPath)
                If line.Length > 0 Then lines.Add(line)
            Next
        End If

        If Not lines.Contains(filename) Then
            lines.Add(filename)
            File.WriteAllText(indexPath, String.Join(Environment.NewLine, lines) & Environment.NewLine)
        End If
    End Sub

    Sub CmdCommit(message As String)
        Dim indexPath As String = Path.Combine(".minigit", "index")
        Dim staged As New List(Of String)
        If File.Exists(indexPath) Then
            For Each line As String In File.ReadAllLines(indexPath)
                If line.Trim().Length > 0 Then staged.Add(line.Trim())
            Next
        End If

        If staged.Count = 0 Then
            Console.WriteLine("Nothing to commit")
            Environment.Exit(1)
        End If

        Dim headPath As String = Path.Combine(".minigit", "HEAD")
        Dim parent As String = "NONE"
        If File.Exists(headPath) Then
            Dim h As String = File.ReadAllText(headPath).Trim()
            If h.Length > 0 Then parent = h
        End If

        Dim timestamp As Long = DateTimeOffset.UtcNow.ToUnixTimeSeconds()

        staged.Sort(StringComparer.Ordinal)

        Dim sb As New StringBuilder()
        sb.Append("parent: ").AppendLine(parent)
        sb.Append("timestamp: ").AppendLine(timestamp.ToString())
        sb.Append("message: ").AppendLine(message)
        sb.AppendLine("files:")

        For Each filename As String In staged
            Dim data As Byte() = File.ReadAllBytes(filename)
            Dim blobHash As String = MiniHash(data)
            sb.Append(filename).Append(" ").AppendLine(blobHash)
        Next

        Dim commitContent As String = sb.ToString()
        Dim commitBytes As Byte() = Encoding.UTF8.GetBytes(commitContent)
        Dim commitHash As String = MiniHash(commitBytes)

        File.WriteAllText(Path.Combine(".minigit", "commits", commitHash), commitContent)
        File.WriteAllText(headPath, commitHash)
        File.WriteAllText(indexPath, "")

        Console.WriteLine("Committed " & commitHash)
    End Sub

    Sub CmdLog()
        Dim headPath As String = Path.Combine(".minigit", "HEAD")
        If Not File.Exists(headPath) OrElse File.ReadAllText(headPath).Trim().Length = 0 Then
            Console.WriteLine("No commits")
            Return
        End If

        Dim current As String = File.ReadAllText(headPath).Trim()

        While current.Length > 0 AndAlso current <> "NONE"
            Dim commitPath As String = Path.Combine(".minigit", "commits", current)
            If Not File.Exists(commitPath) Then Exit While

            Dim content As String = File.ReadAllText(commitPath)
            Dim commitLines As String() = content.Split({vbCrLf, vbLf}, StringSplitOptions.None)

            Dim parentHash As String = "NONE"
            Dim timestamp As String = ""
            Dim msg As String = ""

            For Each line As String In commitLines
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

            If parentHash = "NONE" OrElse parentHash.Length = 0 Then Exit While
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
                    Console.Error.WriteLine("Usage: minigit commit -m <message>")
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
