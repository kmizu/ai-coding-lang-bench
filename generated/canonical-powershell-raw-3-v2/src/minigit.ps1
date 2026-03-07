#!/usr/bin/env pwsh
# No param() block — use automatic $args so PowerShell never interprets
# sub-command flags like -m as named parameters.

$cmdArgs = @($args | Where-Object { $_ -ne '--' })

function MiniHash([byte[]]$bytes) {
    [bigint]$mod  = [bigint]::Pow(2, 64)
    [bigint]$mult = 1099511628211
    [bigint]$h    = 1469598103934665603
    foreach ($b in $bytes) {
        $h = ($h -bxor [bigint]$b)
        $h = ($h * $mult) % $mod
    }
    return $h.ToString('x').PadLeft(16, '0')
}

function FileHash([string]$path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    return MiniHash $bytes
}

# Parse a commit file and return hashtable with parent, timestamp, message, files (hashtable filename->blobhash)
function ParseCommit([string]$commitPath) {
    $lines = [System.IO.File]::ReadAllLines($commitPath)
    $result = @{ parent = 'NONE'; timestamp = ''; message = ''; files = @{} }
    $inFiles = $false
    foreach ($line in $lines) {
        if ($inFiles) {
            if ($line.Trim() -ne '') {
                $parts = $line -split ' ', 2
                if ($parts.Count -eq 2) {
                    $result.files[$parts[0]] = $parts[1]
                }
            }
        } elseif ($line -match '^parent: (.+)$') {
            $result.parent = $matches[1]
        } elseif ($line -match '^timestamp: (.+)$') {
            $result.timestamp = $matches[1]
        } elseif ($line -match '^message: (.+)$') {
            $result.message = $matches[1]
        } elseif ($line -eq 'files:') {
            $inFiles = $true
        }
    }
    return $result
}

$command = if ($cmdArgs.Count -gt 0) { $cmdArgs[0] } else { '' }

switch ($command) {

    'init' {
        if (Test-Path '.minigit') {
            Write-Host "Repository already initialized"
            exit 0
        }
        New-Item -ItemType Directory -Path '.minigit/objects' -Force | Out-Null
        New-Item -ItemType Directory -Path '.minigit/commits' -Force | Out-Null
        [System.IO.File]::WriteAllText('.minigit/index', '')
        [System.IO.File]::WriteAllText('.minigit/HEAD',  '')
        exit 0
    }

    'add' {
        if ($cmdArgs.Count -lt 2) {
            Write-Host "Usage: minigit add <file>"
            exit 1
        }
        $file = $cmdArgs[1]
        if (-not (Test-Path $file -PathType Leaf)) {
            Write-Host "File not found"
            exit 1
        }
        $absFile = (Resolve-Path $file).Path
        $hash    = FileHash $absFile
        Copy-Item $absFile ".minigit/objects/$hash" -Force

        $indexPath = '.minigit/index'
        $existing  = [System.IO.File]::ReadAllText($indexPath) -split "`n" |
                     Where-Object { $_ -ne '' }
        if ($existing -notcontains $file) {
            [System.IO.File]::AppendAllText($indexPath, "$file`n")
        }
        exit 0
    }

    'commit' {
        # Parse -m <message>
        $message = ''
        for ($i = 1; $i -lt $cmdArgs.Count; $i++) {
            if ($cmdArgs[$i] -eq '-m' -and ($i + 1) -lt $cmdArgs.Count) {
                $message = $cmdArgs[$i + 1]
                break
            }
        }

        $indexPath   = '.minigit/index'
        $stagedFiles = [System.IO.File]::ReadAllText($indexPath) -split "`n" |
                       Where-Object { $_ -ne '' }

        if ($stagedFiles.Count -eq 0) {
            Write-Host "Nothing to commit"
            exit 1
        }

        $headContent = [System.IO.File]::ReadAllText('.minigit/HEAD').Trim()
        $parent      = if ($headContent -ne '') { $headContent } else { 'NONE' }
        $timestamp   = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine("parent: $parent")
        [void]$sb.AppendLine("timestamp: $timestamp")
        [void]$sb.AppendLine("message: $message")
        [void]$sb.AppendLine("files:")
        foreach ($f in ($stagedFiles | Sort-Object)) {
            $blobHash = FileHash (Resolve-Path $f).Path
            [void]$sb.AppendLine("$f $blobHash")
        }
        $commitContent = $sb.ToString()

        $commitBytes = [System.Text.Encoding]::UTF8.GetBytes($commitContent)
        $commitHash  = MiniHash $commitBytes

        [System.IO.File]::WriteAllText(".minigit/commits/$commitHash", $commitContent,
            [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText('.minigit/HEAD',  $commitHash)
        [System.IO.File]::WriteAllText('.minigit/index', '')

        Write-Host "Committed $commitHash"
        exit 0
    }

    'status' {
        $indexPath   = '.minigit/index'
        $stagedFiles = [System.IO.File]::ReadAllText($indexPath) -split "`n" |
                       Where-Object { $_ -ne '' }

        Write-Host "Staged files:"
        if ($stagedFiles.Count -eq 0) {
            Write-Host "(none)"
        } else {
            foreach ($f in $stagedFiles) {
                Write-Host $f
            }
        }
        exit 0
    }

    'log' {
        $headContent = [System.IO.File]::ReadAllText('.minigit/HEAD').Trim()
        if ($headContent -eq '') {
            Write-Host "No commits"
            exit 0
        }

        $current = $headContent
        while ($current -ne 'NONE' -and $current -ne '') {
            $commitPath = ".minigit/commits/$current"
            if (-not (Test-Path $commitPath)) { break }

            $lines     = [System.IO.File]::ReadAllLines($commitPath)
            $parent    = 'NONE'
            $timestamp = ''
            $message   = ''
            foreach ($line in $lines) {
                if    ($line -match '^parent: (.+)$')     { $parent    = $matches[1] }
                elseif ($line -match '^timestamp: (.+)$') { $timestamp = $matches[1] }
                elseif ($line -match '^message: (.+)$')   { $message   = $matches[1] }
            }

            Write-Host "commit $current"
            Write-Host "Date: $timestamp"
            Write-Host "Message: $message"
            Write-Host ""

            $current = $parent
        }
        exit 0
    }

    'diff' {
        if ($cmdArgs.Count -lt 3) {
            Write-Host "Usage: minigit diff <commit1> <commit2>"
            exit 1
        }
        $hash1 = $cmdArgs[1]
        $hash2 = $cmdArgs[2]
        $path1 = ".minigit/commits/$hash1"
        $path2 = ".minigit/commits/$hash2"

        if (-not (Test-Path $path1) -or -not (Test-Path $path2)) {
            Write-Host "Invalid commit"
            exit 1
        }

        $c1 = ParseCommit $path1
        $c2 = ParseCommit $path2

        $allFiles = @()
        $allFiles += $c1.files.Keys
        $allFiles += $c2.files.Keys
        $allFiles = $allFiles | Sort-Object -Unique

        foreach ($f in $allFiles) {
            $in1 = $c1.files.ContainsKey($f)
            $in2 = $c2.files.ContainsKey($f)
            if ($in1 -and $in2) {
                if ($c1.files[$f] -ne $c2.files[$f]) {
                    Write-Host "Modified: $f"
                }
            } elseif (-not $in1 -and $in2) {
                Write-Host "Added: $f"
            } elseif ($in1 -and -not $in2) {
                Write-Host "Removed: $f"
            }
        }
        exit 0
    }

    'checkout' {
        if ($cmdArgs.Count -lt 2) {
            Write-Host "Usage: minigit checkout <commit_hash>"
            exit 1
        }
        $hash       = $cmdArgs[1]
        $commitPath = ".minigit/commits/$hash"

        if (-not (Test-Path $commitPath)) {
            Write-Host "Invalid commit"
            exit 1
        }

        $commit = ParseCommit $commitPath
        foreach ($f in $commit.files.Keys) {
            $blobHash   = $commit.files[$f]
            $blobPath   = ".minigit/objects/$blobHash"
            $blobContent = [System.IO.File]::ReadAllBytes($blobPath)
            # Ensure parent directory exists
            $dir = [System.IO.Path]::GetDirectoryName($f)
            if ($dir -and -not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            [System.IO.File]::WriteAllBytes($f, $blobContent)
        }

        [System.IO.File]::WriteAllText('.minigit/HEAD',  $hash)
        [System.IO.File]::WriteAllText('.minigit/index', '')

        Write-Host "Checked out $hash"
        exit 0
    }

    'reset' {
        if ($cmdArgs.Count -lt 2) {
            Write-Host "Usage: minigit reset <commit_hash>"
            exit 1
        }
        $hash       = $cmdArgs[1]
        $commitPath = ".minigit/commits/$hash"

        if (-not (Test-Path $commitPath)) {
            Write-Host "Invalid commit"
            exit 1
        }

        [System.IO.File]::WriteAllText('.minigit/HEAD',  $hash)
        [System.IO.File]::WriteAllText('.minigit/index', '')

        Write-Host "Reset to $hash"
        exit 0
    }

    'rm' {
        if ($cmdArgs.Count -lt 2) {
            Write-Host "Usage: minigit rm <file>"
            exit 1
        }
        $file      = $cmdArgs[1]
        $indexPath = '.minigit/index'
        $existing  = [System.IO.File]::ReadAllText($indexPath) -split "`n" |
                     Where-Object { $_ -ne '' }

        if ($existing -notcontains $file) {
            Write-Host "File not in index"
            exit 1
        }

        $updated = $existing | Where-Object { $_ -ne $file }
        $newContent = if ($updated) { ($updated -join "`n") + "`n" } else { '' }
        [System.IO.File]::WriteAllText($indexPath, $newContent)
        exit 0
    }

    'show' {
        if ($cmdArgs.Count -lt 2) {
            Write-Host "Usage: minigit show <commit_hash>"
            exit 1
        }
        $hash       = $cmdArgs[1]
        $commitPath = ".minigit/commits/$hash"

        if (-not (Test-Path $commitPath)) {
            Write-Host "Invalid commit"
            exit 1
        }

        $commit = ParseCommit $commitPath
        Write-Host "commit $hash"
        Write-Host "Date: $($commit.timestamp)"
        Write-Host "Message: $($commit.message)"
        Write-Host "Files:"
        foreach ($f in ($commit.files.Keys | Sort-Object)) {
            Write-Host "  $f $($commit.files[$f])"
        }
        exit 0
    }

    default {
        Write-Host "Unknown command: $command"
        exit 1
    }
}
