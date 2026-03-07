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

    default {
        Write-Host "Unknown command: $command"
        exit 1
    }
}
