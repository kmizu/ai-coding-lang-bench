#!/usr/bin/env pwsh

function MiniHash([byte[]]$bytes) {
    $two64 = [System.Numerics.BigInteger]::Pow(2, 64)
    $mult  = [System.Numerics.BigInteger]::Parse('1099511628211')
    $h     = [System.Numerics.BigInteger]::Parse('1469598103934665603')
    foreach ($b in $bytes) {
        # h is always in [0, 2^64); uint64 cast for XOR, then back to BigInteger
        [uint64]$hU = [uint64]$h
        $hU = $hU -bxor [uint64]$b
        $h = [System.Numerics.BigInteger]$hU
        $h = [System.Numerics.BigInteger]::Remainder($h * $mult, $two64)
    }
    # Convert to uint64 first to get clean 16-char hex (BigInteger.ToString('x')
    # may add a leading '0' sign byte when the high bit of the 64-bit value is set)
    [uint64]$result = [uint64]$h
    return $result.ToString('x16')
}

# Collect args into a typed string array; strip leading '--' from launcher
$allArgs = [string[]]$args
$start   = 0
if ($allArgs.Count -gt 0 -and $allArgs[0] -eq '--') { $start = 1 }

if (($allArgs.Count - $start) -eq 0) {
    Write-Host "Usage: minigit <command>"
    exit 1
}

$cmd  = $allArgs[$start]
$rest = [string[]]@()
for ($i = $start + 1; $i -lt $allArgs.Count; $i++) {
    $rest += $allArgs[$i]
}

$repoDir = Join-Path (Get-Location) '.minigit'

switch ($cmd) {

    'init' {
        if (Test-Path $repoDir) {
            Write-Host "Repository already initialized"
            exit 0
        }
        New-Item -ItemType Directory -Path (Join-Path $repoDir 'objects') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $repoDir 'commits') -Force | Out-Null
        [System.IO.File]::WriteAllText((Join-Path $repoDir 'index'), '')
        [System.IO.File]::WriteAllText((Join-Path $repoDir 'HEAD'),  '')
        exit 0
    }

    'add' {
        if ($rest.Count -eq 0) {
            Write-Host "Usage: minigit add <file>"
            exit 1
        }
        $file = $rest[0]
        if (-not (Test-Path $file -PathType Leaf)) {
            Write-Host "File not found"
            exit 1
        }
        $absFile = (Resolve-Path $file).Path
        $bytes   = [System.IO.File]::ReadAllBytes($absFile)
        $hash    = MiniHash $bytes

        $objPath = Join-Path $repoDir "objects/$hash"
        [System.IO.File]::WriteAllBytes($objPath, $bytes)

        $indexPath = Join-Path $repoDir 'index'
        $existing  = [System.IO.File]::ReadAllLines($indexPath) | Where-Object { $_ -ne '' }
        if ($existing -notcontains $file) {
            [System.IO.File]::AppendAllText($indexPath, "$file`n")
        }
        exit 0
    }

    'commit' {
        if ($rest.Count -lt 2 -or $rest[0] -ne '-m') {
            Write-Host "Usage: minigit commit -m <message>"
            exit 1
        }
        $message = $rest[1]

        $indexPath = Join-Path $repoDir 'index'
        $staged    = [System.IO.File]::ReadAllLines($indexPath) | Where-Object { $_ -ne '' }
        if ($staged.Count -eq 0) {
            Write-Host "Nothing to commit"
            exit 1
        }

        $headPath = Join-Path $repoDir 'HEAD'
        $parent   = ([System.IO.File]::ReadAllText($headPath)).Trim()
        if ($parent -eq '') { $parent = 'NONE' }

        $ts = [System.DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

        $sorted    = $staged | Sort-Object
        $fileLines = [string[]]@()
        foreach ($f in $sorted) {
            $absF  = Join-Path (Get-Location) $f
            $fHash = MiniHash ([System.IO.File]::ReadAllBytes($absF))
            $fileLines += "$f $fHash"
        }

        $content = "parent: $parent`ntimestamp: $ts`nmessage: $message`nfiles:`n" +
                   ($fileLines -join "`n") + "`n"

        $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        $commitHash   = MiniHash $contentBytes

        [System.IO.File]::WriteAllText((Join-Path $repoDir "commits/$commitHash"), $content)
        [System.IO.File]::WriteAllText($headPath, $commitHash)
        [System.IO.File]::WriteAllText($indexPath, '')

        Write-Host "Committed $commitHash"
        exit 0
    }

    'log' {
        $headPath = Join-Path $repoDir 'HEAD'
        $current  = ([System.IO.File]::ReadAllText($headPath)).Trim()
        if ($current -eq '') {
            Write-Host "No commits"
            exit 0
        }
        while ($current -ne '' -and $current -ne 'NONE') {
            $commitFile = Join-Path $repoDir "commits/$current"
            if (-not (Test-Path $commitFile)) { break }
            $lines = [System.IO.File]::ReadAllLines($commitFile)
            # Use Select-Object -First 1 to avoid PowerShell's single-item
            # unwrapping: [0] on a bare string gives a char, not the string.
            $parent = ($lines | Where-Object { $_ -match '^parent: '    } | Select-Object -First 1) -replace '^parent: '
            $ts     = ($lines | Where-Object { $_ -match '^timestamp: ' } | Select-Object -First 1) -replace '^timestamp: '
            $msg    = ($lines | Where-Object { $_ -match '^message: '   } | Select-Object -First 1) -replace '^message: '
            Write-Host "commit $current"
            Write-Host "Date: $ts"
            Write-Host "Message: $msg"
            Write-Host ''
            if ($parent -eq 'NONE') { break }
            $current = $parent
        }
        exit 0
    }

    default {
        Write-Host "Unknown command: $cmd"
        exit 1
    }
}
