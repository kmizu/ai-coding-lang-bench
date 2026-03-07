#!/usr/bin/env pwsh
# No param() block: all arguments land in the automatic $args variable,
# so -m etc. are NOT interpreted as named parameters.

function Get-MiniHash {
    param([byte[]]$Data)
    [uint64]$h = 1469598103934665603
    [bigint]$mod = [bigint]::Pow(2, 64)
    foreach ($b in $Data) {
        $h = $h -bxor [uint64]$b
        [bigint]$tmp = ([bigint]$h * [bigint]1099511628211) % $mod
        $h = [uint64]$tmp
    }
    return $h.ToString('x16')
}

# Filter out '--' separator injected by the launcher
$argv = @($args | Where-Object { $_ -ne '--' })

if ($argv.Count -eq 0) {
    $host.ui.WriteErrorLine("Usage: minigit <command> [args]")
    exit 1
}

$cmd  = $argv[0]
$rest = @()
if ($argv.Count -gt 1) { $rest = @($argv[1..($argv.Count - 1)]) }

switch ($cmd) {
    'init' {
        if (Test-Path '.minigit') {
            Write-Output "Repository already initialized"
        } else {
            New-Item -ItemType Directory -Path '.minigit/objects' -Force | Out-Null
            New-Item -ItemType Directory -Path '.minigit/commits' -Force | Out-Null
            [System.IO.File]::WriteAllText("$PWD/.minigit/index", '')
            [System.IO.File]::WriteAllText("$PWD/.minigit/HEAD",  '')
        }
        exit 0
    }

    'add' {
        if ($rest.Count -eq 0) {
            $host.ui.WriteErrorLine("Usage: minigit add <file>")
            exit 1
        }
        $file = $rest[0]
        if (-not (Test-Path $file)) {
            $host.ui.WriteErrorLine("File not found")
            exit 1
        }
        $fullPath = (Resolve-Path $file).ProviderPath
        $bytes    = [System.IO.File]::ReadAllBytes($fullPath)
        $hash     = Get-MiniHash $bytes

        Copy-Item -Path $file -Destination "$PWD/.minigit/objects/$hash" -Force

        $indexPath = "$PWD/.minigit/index"
        $existing  = if (Test-Path $indexPath) {
            [System.IO.File]::ReadAllText($indexPath) -split "`n" | Where-Object { $_ -ne '' }
        } else { @() }

        $alreadyStaged = $existing | Where-Object { ($_ -split ' ', 2)[0] -eq $file }
        if (-not $alreadyStaged) {
            [System.IO.File]::AppendAllText($indexPath, "$file $hash`n")
        }
        exit 0
    }

    'commit' {
        # Parse -m <message>
        $message = ''
        for ($i = 0; $i -lt $rest.Count - 1; $i++) {
            if ($rest[$i] -eq '-m') {
                $message = $rest[$i + 1]
                break
            }
        }

        $indexPath  = "$PWD/.minigit/index"
        $indexLines = if (Test-Path $indexPath) {
            [System.IO.File]::ReadAllText($indexPath) -split "`n" | Where-Object { $_ -ne '' }
        } else { @() }

        if ($indexLines.Count -eq 0) {
            $host.ui.WriteErrorLine("Nothing to commit")
            exit 1
        }

        # Build filename->hash map from index
        $fileMap = [System.Collections.Generic.Dictionary[string,string]]::new()
        foreach ($line in $indexLines) {
            $parts = $line -split ' ', 2
            if ($parts.Count -eq 2) {
                $fileMap[$parts[0]] = $parts[1]
            }
        }

        $sortedFiles = $fileMap.Keys | Sort-Object

        # Parent hash
        $headPath = "$PWD/.minigit/HEAD"
        $parent   = 'NONE'
        if (Test-Path $headPath) {
            $h = ([System.IO.File]::ReadAllText($headPath)).Trim()
            if ($h) { $parent = $h }
        }

        $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.Append("parent: $parent`n")
        [void]$sb.Append("timestamp: $timestamp`n")
        [void]$sb.Append("message: $message`n")
        [void]$sb.Append("files:`n")
        foreach ($f in $sortedFiles) {
            [void]$sb.Append("$f $($fileMap[$f])`n")
        }
        $commitContent = $sb.ToString()

        $commitBytes = [System.Text.Encoding]::UTF8.GetBytes($commitContent)
        $commitHash  = Get-MiniHash $commitBytes

        [System.IO.File]::WriteAllText("$PWD/.minigit/commits/$commitHash", $commitContent)
        [System.IO.File]::WriteAllText($headPath, $commitHash)
        [System.IO.File]::WriteAllText($indexPath, '')

        Write-Output "Committed $commitHash"
        exit 0
    }

    'log' {
        $headPath = "$PWD/.minigit/HEAD"
        $current  = ''
        if (Test-Path $headPath) {
            $current = ([System.IO.File]::ReadAllText($headPath)).Trim()
        }

        if (-not $current) {
            Write-Output "No commits"
            exit 0
        }

        while ($current -and $current -ne 'NONE') {
            $commitPath = "$PWD/.minigit/commits/$current"
            if (-not (Test-Path $commitPath)) { break }

            $lines     = [System.IO.File]::ReadAllText($commitPath) -split "`n"
            $parent    = 'NONE'
            $timestamp = ''
            $message   = ''

            foreach ($line in $lines) {
                if ($line -match '^parent: (.+)$')        { $parent    = $Matches[1].Trim() }
                elseif ($line -match '^timestamp: (.+)$') { $timestamp = $Matches[1].Trim() }
                elseif ($line -match '^message: (.+)$')   { $message   = $Matches[1].Trim() }
            }

            Write-Output "commit $current"
            Write-Output "Date: $timestamp"
            Write-Output "Message: $message"
            Write-Output ""

            $current = $parent
        }
        exit 0
    }

    'status' {
        $indexPath = "$PWD/.minigit/index"
        $staged = if (Test-Path $indexPath) {
            [System.IO.File]::ReadAllText($indexPath) -split "`n" | Where-Object { $_ -ne '' }
        } else { @() }

        Write-Output "Staged files:"
        if ($staged.Count -eq 0) {
            Write-Output "(none)"
        } else {
            foreach ($line in $staged) {
                $parts = $line -split ' ', 2
                Write-Output $parts[0]
            }
        }
        exit 0
    }

    'diff' {
        if ($rest.Count -lt 2) {
            $host.ui.WriteErrorLine("Usage: minigit diff <commit1> <commit2>")
            exit 1
        }
        $hash1 = $rest[0]
        $hash2 = $rest[1]
        $path1 = "$PWD/.minigit/commits/$hash1"
        $path2 = "$PWD/.minigit/commits/$hash2"

        if (-not (Test-Path $path1) -or -not (Test-Path $path2)) {
            Write-Output "Invalid commit"
            exit 1
        }

        function Parse-CommitFiles($commitPath) {
            $lines = [System.IO.File]::ReadAllText($commitPath) -split "`n"
            $inFiles = $false
            $map = [System.Collections.Generic.Dictionary[string,string]]::new()
            foreach ($line in $lines) {
                if ($line -eq 'files:') { $inFiles = $true; continue }
                if ($inFiles -and $line -ne '') {
                    $parts = $line -split ' ', 2
                    if ($parts.Count -eq 2) { $map[$parts[0]] = $parts[1] }
                }
            }
            return $map
        }

        $files1 = Parse-CommitFiles $path1
        $files2 = Parse-CommitFiles $path2

        $allFiles = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($k in $files1.Keys) { [void]$allFiles.Add($k) }
        foreach ($k in $files2.Keys) { [void]$allFiles.Add($k) }

        foreach ($f in ($allFiles | Sort-Object)) {
            $in1 = $files1.ContainsKey($f)
            $in2 = $files2.ContainsKey($f)
            if ($in1 -and $in2) {
                if ($files1[$f] -ne $files2[$f]) { Write-Output "Modified: $f" }
            } elseif ($in2) {
                Write-Output "Added: $f"
            } else {
                Write-Output "Removed: $f"
            }
        }
        exit 0
    }

    'checkout' {
        if ($rest.Count -eq 0) {
            $host.ui.WriteErrorLine("Usage: minigit checkout <commit_hash>")
            exit 1
        }
        $targetHash = $rest[0]
        $commitPath = "$PWD/.minigit/commits/$targetHash"

        if (-not (Test-Path $commitPath)) {
            Write-Output "Invalid commit"
            exit 1
        }

        $lines = [System.IO.File]::ReadAllText($commitPath) -split "`n"
        $inFiles = $false
        foreach ($line in $lines) {
            if ($line -eq 'files:') { $inFiles = $true; continue }
            if ($inFiles -and $line -ne '') {
                $parts = $line -split ' ', 2
                if ($parts.Count -eq 2) {
                    $blobPath = "$PWD/.minigit/objects/$($parts[1])"
                    if (Test-Path $blobPath) {
                        Copy-Item -Path $blobPath -Destination "$PWD/$($parts[0])" -Force
                    }
                }
            }
        }

        [System.IO.File]::WriteAllText("$PWD/.minigit/HEAD", $targetHash)
        [System.IO.File]::WriteAllText("$PWD/.minigit/index", '')
        Write-Output "Checked out $targetHash"
        exit 0
    }

    'reset' {
        if ($rest.Count -eq 0) {
            $host.ui.WriteErrorLine("Usage: minigit reset <commit_hash>")
            exit 1
        }
        $targetHash = $rest[0]
        $commitPath = "$PWD/.minigit/commits/$targetHash"

        if (-not (Test-Path $commitPath)) {
            Write-Output "Invalid commit"
            exit 1
        }

        [System.IO.File]::WriteAllText("$PWD/.minigit/HEAD", $targetHash)
        [System.IO.File]::WriteAllText("$PWD/.minigit/index", '')
        Write-Output "Reset to $targetHash"
        exit 0
    }

    'rm' {
        if ($rest.Count -eq 0) {
            $host.ui.WriteErrorLine("Usage: minigit rm <file>")
            exit 1
        }
        $file = $rest[0]
        $indexPath = "$PWD/.minigit/index"
        $lines = if (Test-Path $indexPath) {
            [System.IO.File]::ReadAllText($indexPath) -split "`n" | Where-Object { $_ -ne '' }
        } else { @() }

        $matching = @($lines | Where-Object { ($_ -split ' ', 2)[0] -eq $file })
        if ($matching.Count -eq 0) {
            Write-Output "File not in index"
            exit 1
        }

        $newLines = @($lines | Where-Object { ($_ -split ' ', 2)[0] -ne $file })
        $newContent = if ($newLines.Count -gt 0) { ($newLines -join "`n") + "`n" } else { '' }
        [System.IO.File]::WriteAllText($indexPath, $newContent)
        exit 0
    }

    'show' {
        if ($rest.Count -eq 0) {
            $host.ui.WriteErrorLine("Usage: minigit show <commit_hash>")
            exit 1
        }
        $targetHash = $rest[0]
        $commitPath = "$PWD/.minigit/commits/$targetHash"

        if (-not (Test-Path $commitPath)) {
            Write-Output "Invalid commit"
            exit 1
        }

        $lines = [System.IO.File]::ReadAllText($commitPath) -split "`n"
        $timestamp = ''
        $message   = ''
        $fileLines = [System.Collections.Generic.List[string]]::new()
        $inFiles   = $false

        foreach ($line in $lines) {
            if ($line -match '^timestamp: (.+)$')      { $timestamp = $Matches[1].Trim() }
            elseif ($line -match '^message: (.+)$')    { $message   = $Matches[1].Trim() }
            elseif ($line -eq 'files:')                { $inFiles   = $true }
            elseif ($inFiles -and $line -ne '')        { $fileLines.Add($line) }
        }

        Write-Output "commit $targetHash"
        Write-Output "Date: $timestamp"
        Write-Output "Message: $message"
        Write-Output "Files:"
        foreach ($fl in ($fileLines | Sort-Object)) {
            Write-Output "  $fl"
        }
        exit 0
    }

    default {
        $host.ui.WriteErrorLine("Unknown command: $cmd")
        exit 1
    }
}
