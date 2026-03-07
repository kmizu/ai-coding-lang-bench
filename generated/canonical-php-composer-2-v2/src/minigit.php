<?php
declare(strict_types=1);

/**
 * MiniHash: FNV-1a variant, 64-bit, 16-char hex output.
 * Uses (hi32, lo32) pairs to avoid PHP float overflow on 64-bit multiply.
 *
 * m = 1099511628211 = 256 * 2^32 + 435  (m_hi=256, m_lo=435)
 */
function miniHash(string $data): string {
    $init = 1469598103934665603; // fits in PHP_INT_MAX, no float conversion
    $h_hi = intdiv($init, 4294967296);
    $h_lo = $init - $h_hi * 4294967296;

    // m = 1099511628211 = 256*2^32 + 435
    $m_hi = 256;
    $m_lo = 435;

    $len = strlen($data);
    for ($i = 0; $i < $len; $i++) {
        // XOR h with byte (only low 8 bits affected, stay within h_lo)
        $h_lo = ($h_lo ^ ord($data[$i])) & 0xFFFFFFFF;

        // Multiply (h_hi:h_lo) * m, keep low 64 bits
        // (h_hi*2^32 + h_lo) * (m_hi*2^32 + m_lo) mod 2^64
        // = (h_hi*m_lo + h_lo*m_hi)*2^32 + h_lo*m_lo   mod 2^64
        $P0     = $h_lo * $m_lo; // max ~1.87e12, fits in PHP int
        $P1     = $h_lo * $m_hi; // max ~1.1e12
        $P2     = $h_hi * $m_lo; // max ~1.87e12

        $P0_lo  = $P0 & 0xFFFFFFFF;
        $P0_hi  = intdiv($P0, 4294967296);          // carry into upper word

        $sum_hi = $P1 + $P2 + $P0_hi; // max ~2.97e12, fits in PHP int

        $h_lo = $P0_lo;
        $h_hi = $sum_hi & 0xFFFFFFFF;
    }

    return sprintf('%08x%08x', $h_hi, $h_lo);
}

function repoDir(): string {
    return getcwd() . '/.minigit';
}

function cmdInit(): void {
    $repo = repoDir();
    if (is_dir($repo)) {
        echo "Repository already initialized\n";
        exit(0);
    }
    mkdir($repo . '/objects', 0755, true);
    mkdir($repo . '/commits', 0755, true);
    file_put_contents($repo . '/index', '');
    file_put_contents($repo . '/HEAD', '');
    exit(0);
}

function cmdAdd(string $file): void {
    $repo = repoDir();
    if (!file_exists($file)) {
        echo "File not found\n";
        exit(1);
    }

    $content = file_get_contents($file);
    $hash    = miniHash($content);

    file_put_contents($repo . '/objects/' . $hash, $content);

    // Index stores "filename blobhash" per line
    $indexFile = $repo . '/index';
    $raw       = (string)file_get_contents($indexFile);
    $lines     = ($raw !== '') ? explode("\n", rtrim($raw)) : [];

    $found = false;
    foreach ($lines as &$line) {
        $parts = explode(' ', $line, 2);
        if ($parts[0] === $file) {
            $line  = "$file $hash";
            $found = true;
            break;
        }
    }
    unset($line);

    if (!$found) {
        $lines[] = "$file $hash";
    }

    file_put_contents($indexFile, implode("\n", $lines) . "\n");
    exit(0);
}

function cmdCommit(string $message): void {
    $repo      = repoDir();
    $indexFile = $repo . '/index';
    $raw       = trim((string)file_get_contents($indexFile));

    if ($raw === '') {
        echo "Nothing to commit\n";
        exit(1);
    }

    $fileMap = [];
    foreach (explode("\n", $raw) as $line) {
        $line = trim($line);
        if ($line === '') continue;
        [$fn, $bh] = explode(' ', $line, 2);
        $fileMap[$fn] = $bh;
    }
    ksort($fileMap);

    $headFile = $repo . '/HEAD';
    $parent   = trim((string)file_get_contents($headFile));
    if ($parent === '') {
        $parent = 'NONE';
    }

    $timestamp = time();

    $body  = "parent: $parent\n";
    $body .= "timestamp: $timestamp\n";
    $body .= "message: $message\n";
    $body .= "files:\n";
    foreach ($fileMap as $fn => $bh) {
        $body .= "$fn $bh\n";
    }

    $commitHash = miniHash($body);

    file_put_contents($repo . '/commits/' . $commitHash, $body);
    file_put_contents($headFile, $commitHash . "\n");
    file_put_contents($indexFile, '');

    echo "Committed $commitHash\n";
    exit(0);
}

function parseCommit(string $content): array {
    $result = ['parent' => 'NONE', 'timestamp' => '', 'message' => '', 'files' => []];
    $inFiles = false;
    foreach (explode("\n", $content) as $line) {
        if ($inFiles) {
            $line = rtrim($line);
            if ($line === '') continue;
            $parts = explode(' ', $line, 2);
            if (count($parts) === 2) {
                $result['files'][$parts[0]] = $parts[1];
            }
        } elseif (str_starts_with($line, 'parent: ')) {
            $result['parent'] = substr($line, 8);
        } elseif (str_starts_with($line, 'timestamp: ')) {
            $result['timestamp'] = substr($line, 11);
        } elseif (str_starts_with($line, 'message: ')) {
            $result['message'] = substr($line, 9);
        } elseif ($line === 'files:') {
            $inFiles = true;
        }
    }
    return $result;
}

function cmdStatus(): void {
    $repo      = repoDir();
    $indexFile = $repo . '/index';
    $raw       = trim((string)file_get_contents($indexFile));

    echo "Staged files:\n";
    if ($raw === '') {
        echo "(none)\n";
    } else {
        foreach (explode("\n", $raw) as $line) {
            $line = trim($line);
            if ($line === '') continue;
            $parts = explode(' ', $line, 2);
            echo $parts[0] . "\n";
        }
    }
    exit(0);
}

function cmdDiff(string $hash1, string $hash2): void {
    $repo = repoDir();
    $f1   = $repo . '/commits/' . $hash1;
    $f2   = $repo . '/commits/' . $hash2;

    if (!file_exists($f1) || !file_exists($f2)) {
        echo "Invalid commit\n";
        exit(1);
    }

    $c1 = parseCommit((string)file_get_contents($f1));
    $c2 = parseCommit((string)file_get_contents($f2));

    $files1 = $c1['files'];
    $files2 = $c2['files'];
    $allFiles = array_unique(array_merge(array_keys($files1), array_keys($files2)));
    sort($allFiles);

    foreach ($allFiles as $fn) {
        $in1 = array_key_exists($fn, $files1);
        $in2 = array_key_exists($fn, $files2);

        if ($in1 && !$in2) {
            echo "Removed: $fn\n";
        } elseif (!$in1 && $in2) {
            echo "Added: $fn\n";
        } elseif ($files1[$fn] !== $files2[$fn]) {
            echo "Modified: $fn\n";
        }
    }
    exit(0);
}

function cmdCheckout(string $hash): void {
    $repo       = repoDir();
    $commitFile = $repo . '/commits/' . $hash;

    if (!file_exists($commitFile)) {
        echo "Invalid commit\n";
        exit(1);
    }

    $c = parseCommit((string)file_get_contents($commitFile));

    foreach ($c['files'] as $fn => $bh) {
        $blobPath = $repo . '/objects/' . $bh;
        $content  = (string)file_get_contents($blobPath);
        $dir = dirname($fn);
        if ($dir !== '.' && !is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
        file_put_contents($fn, $content);
    }

    file_put_contents($repo . '/HEAD', $hash . "\n");
    file_put_contents($repo . '/index', '');

    echo "Checked out $hash\n";
    exit(0);
}

function cmdReset(string $hash): void {
    $repo       = repoDir();
    $commitFile = $repo . '/commits/' . $hash;

    if (!file_exists($commitFile)) {
        echo "Invalid commit\n";
        exit(1);
    }

    file_put_contents($repo . '/HEAD', $hash . "\n");
    file_put_contents($repo . '/index', '');

    echo "Reset to $hash\n";
    exit(0);
}

function cmdRm(string $file): void {
    $repo      = repoDir();
    $indexFile = $repo . '/index';
    $raw       = (string)file_get_contents($indexFile);
    $lines     = ($raw !== '') ? explode("\n", rtrim($raw)) : [];

    $found = false;
    $newLines = [];
    foreach ($lines as $line) {
        $line = rtrim($line);
        if ($line === '') continue;
        $parts = explode(' ', $line, 2);
        if ($parts[0] === $file) {
            $found = true;
        } else {
            $newLines[] = $line;
        }
    }

    if (!$found) {
        echo "File not in index\n";
        exit(1);
    }

    $out = count($newLines) > 0 ? implode("\n", $newLines) . "\n" : '';
    file_put_contents($indexFile, $out);
    exit(0);
}

function cmdShow(string $hash): void {
    $repo       = repoDir();
    $commitFile = $repo . '/commits/' . $hash;

    if (!file_exists($commitFile)) {
        echo "Invalid commit\n";
        exit(1);
    }

    $c = parseCommit((string)file_get_contents($commitFile));

    echo "commit $hash\n";
    echo "Date: {$c['timestamp']}\n";
    echo "Message: {$c['message']}\n";
    echo "Files:\n";

    $files = $c['files'];
    ksort($files);
    foreach ($files as $fn => $bh) {
        echo "  $fn $bh\n";
    }
    exit(0);
}

function cmdLog(): void {
    $repo     = repoDir();
    $headFile = $repo . '/HEAD';
    $head     = trim((string)file_get_contents($headFile));

    if ($head === '') {
        echo "No commits\n";
        exit(0);
    }

    $hash = $head;
    while ($hash !== '' && $hash !== 'NONE') {
        $commitFile = $repo . '/commits/' . $hash;
        if (!file_exists($commitFile)) break;

        $content   = (string)file_get_contents($commitFile);
        $parent    = 'NONE';
        $timestamp = '';
        $message   = '';

        foreach (explode("\n", $content) as $line) {
            if (str_starts_with($line, 'parent: ')) {
                $parent = substr($line, 8);
            } elseif (str_starts_with($line, 'timestamp: ')) {
                $timestamp = substr($line, 11);
            } elseif (str_starts_with($line, 'message: ')) {
                $message = substr($line, 9);
            }
        }

        echo "commit $hash\n";
        echo "Date: $timestamp\n";
        echo "Message: $message\n";
        echo "\n";

        $hash = ($parent === 'NONE') ? '' : $parent;
    }

    exit(0);
}

// --- Entrypoint ---

$args = $argv;
array_shift($args);

if (count($args) === 0) {
    fwrite(STDERR, "Usage: minigit <command> [args]\n");
    exit(1);
}

$cmd = array_shift($args);

switch ($cmd) {
    case 'init':
        cmdInit();
        break;

    case 'add':
        if (count($args) < 1) {
            fwrite(STDERR, "Usage: minigit add <file>\n");
            exit(1);
        }
        cmdAdd($args[0]);
        break;

    case 'commit':
        if (count($args) < 2 || $args[0] !== '-m') {
            fwrite(STDERR, "Usage: minigit commit -m \"<message>\"\n");
            exit(1);
        }
        cmdCommit($args[1]);
        break;

    case 'log':
        cmdLog();
        break;

    case 'status':
        cmdStatus();
        break;

    case 'diff':
        if (count($args) < 2) {
            fwrite(STDERR, "Usage: minigit diff <commit1> <commit2>\n");
            exit(1);
        }
        cmdDiff($args[0], $args[1]);
        break;

    case 'checkout':
        if (count($args) < 1) {
            fwrite(STDERR, "Usage: minigit checkout <commit_hash>\n");
            exit(1);
        }
        cmdCheckout($args[0]);
        break;

    case 'reset':
        if (count($args) < 1) {
            fwrite(STDERR, "Usage: minigit reset <commit_hash>\n");
            exit(1);
        }
        cmdReset($args[0]);
        break;

    case 'rm':
        if (count($args) < 1) {
            fwrite(STDERR, "Usage: minigit rm <file>\n");
            exit(1);
        }
        cmdRm($args[0]);
        break;

    case 'show':
        if (count($args) < 1) {
            fwrite(STDERR, "Usage: minigit show <commit_hash>\n");
            exit(1);
        }
        cmdShow($args[0]);
        break;

    default:
        fwrite(STDERR, "Unknown command: $cmd\n");
        exit(1);
}
