<?php
declare(strict_types=1);

/**
 * MiniHash: FNV-1a variant, 64-bit unsigned, 16-char hex output.
 *
 * Implemented using four 16-bit limbs (little-endian) to avoid PHP's
 * lack of native 64-bit unsigned arithmetic and extension dependencies.
 *
 * Multiplier 1099511628211 = 2^40 + 435, expressed as 16-bit limbs:
 *   [435, 0, 256, 0]  (since bit 40 falls in limb[2] as 2^(40-32) = 256)
 */
function miniHash(string $data): string {
    $init = 1469598103934665603; // fits in signed 64-bit, so PHP int is fine
    $h = [
        $init & 0xFFFF,
        ($init >> 16) & 0xFFFF,
        ($init >> 32) & 0xFFFF,
        ($init >> 48) & 0xFFFF,
    ];

    $len = strlen($data);
    for ($i = 0; $i < $len; $i++) {
        // XOR with byte (affects only bits 0-7, i.e. low part of limb 0)
        $h[0] ^= ord($data[$i]);

        // Multiply by 1099511628211 mod 2^64
        // b = [435, 0, 256, 0] in 16-bit limbs
        // result[k] = sum_{i+j=k} h[i]*b[j], then carry-propagate
        $r0 = $h[0] * 435;
        $r1 = $h[1] * 435;
        $r2 = $h[2] * 435 + $h[0] * 256;
        $r3 = $h[3] * 435 + $h[1] * 256;

        $r1 += ($r0 >> 16); $r0 &= 0xFFFF;
        $r2 += ($r1 >> 16); $r1 &= 0xFFFF;
        $r3 += ($r2 >> 16); $r2 &= 0xFFFF;
                             $r3 &= 0xFFFF; // discard overflow (mod 2^64)

        $h = [$r0, $r1, $r2, $r3];
    }

    return sprintf('%04x%04x%04x%04x', $h[3], $h[2], $h[1], $h[0]);
}

function repoRoot(): string {
    return getcwd() . '/.minigit';
}

function cmdInit(): void {
    $root = repoRoot();
    if (is_dir($root)) {
        echo "Repository already initialized\n";
        exit(0);
    }
    mkdir($root . '/objects', 0755, true);
    mkdir($root . '/commits', 0755, true);
    file_put_contents($root . '/index', '');
    file_put_contents($root . '/HEAD', '');
    exit(0);
}

function cmdAdd(string $file): void {
    $root = repoRoot();
    if (!file_exists($file)) {
        echo "File not found\n";
        exit(1);
    }

    $content = file_get_contents($file);
    $hash = miniHash($content);

    file_put_contents($root . '/objects/' . $hash, $content);

    $raw = file_get_contents($root . '/index');
    $staged = ($raw === '') ? [] : array_filter(explode("\n", $raw));
    if (!in_array($file, $staged, true)) {
        file_put_contents($root . '/index', $raw . $file . "\n");
    }

    exit(0);
}

function cmdCommit(string $message): void {
    $root = repoRoot();
    $raw = file_get_contents($root . '/index');
    $staged = array_values(array_filter(explode("\n", $raw)));

    if (count($staged) === 0) {
        echo "Nothing to commit\n";
        exit(1);
    }

    $head = trim(file_get_contents($root . '/HEAD'));
    $parentStr = ($head === '') ? 'NONE' : $head;
    $timestamp = time();

    sort($staged);

    $fileLines = '';
    foreach ($staged as $file) {
        $hash = miniHash(file_get_contents($file));
        $fileLines .= $file . ' ' . $hash . "\n";
    }

    $commitContent = "parent: $parentStr\ntimestamp: $timestamp\nmessage: $message\nfiles:\n$fileLines";
    $commitHash = miniHash($commitContent);

    file_put_contents($root . '/commits/' . $commitHash, $commitContent);
    file_put_contents($root . '/HEAD', $commitHash);
    file_put_contents($root . '/index', '');

    echo "Committed $commitHash\n";
    exit(0);
}

function cmdLog(): void {
    $root = repoRoot();
    $head = trim(file_get_contents($root . '/HEAD'));

    if ($head === '') {
        echo "No commits\n";
        exit(0);
    }

    $current = $head;
    while ($current !== '' && $current !== 'NONE') {
        $commitFile = $root . '/commits/' . $current;
        if (!file_exists($commitFile)) {
            break;
        }

        $parent = 'NONE';
        $timestamp = '';
        $message = '';

        foreach (explode("\n", file_get_contents($commitFile)) as $line) {
            if (str_starts_with($line, 'parent: ')) {
                $parent = substr($line, 8);
            } elseif (str_starts_with($line, 'timestamp: ')) {
                $timestamp = substr($line, 11);
            } elseif (str_starts_with($line, 'message: ')) {
                $message = substr($line, 9);
            }
        }

        echo "commit $current\n";
        echo "Date: $timestamp\n";
        echo "Message: $message\n";
        echo "\n";

        $current = ($parent === 'NONE') ? '' : $parent;
    }

    exit(0);
}

function cmdStatus(): void {
    $root = repoRoot();
    $raw = file_get_contents($root . '/index');
    $staged = array_values(array_filter(explode("\n", $raw)));

    echo "Staged files:\n";
    if (count($staged) === 0) {
        echo "(none)\n";
    } else {
        foreach ($staged as $f) {
            echo "$f\n";
        }
    }
    exit(0);
}

function parseCommitFiles(string $commitContent): array {
    $files = [];
    $inFiles = false;
    foreach (explode("\n", $commitContent) as $line) {
        if ($line === 'files:') {
            $inFiles = true;
            continue;
        }
        if ($inFiles && $line !== '') {
            $parts = explode(' ', $line, 2);
            if (count($parts) === 2) {
                $files[$parts[0]] = $parts[1];
            }
        }
    }
    return $files;
}

function loadCommit(string $root, string $hash): ?array {
    $commitFile = $root . '/commits/' . $hash;
    if (!file_exists($commitFile)) {
        return null;
    }
    $content = file_get_contents($commitFile);
    $data = ['parent' => 'NONE', 'timestamp' => '', 'message' => '', 'files' => []];
    foreach (explode("\n", $content) as $line) {
        if (str_starts_with($line, 'parent: ')) {
            $data['parent'] = substr($line, 8);
        } elseif (str_starts_with($line, 'timestamp: ')) {
            $data['timestamp'] = substr($line, 11);
        } elseif (str_starts_with($line, 'message: ')) {
            $data['message'] = substr($line, 9);
        }
    }
    $data['files'] = parseCommitFiles($content);
    return $data;
}

function cmdDiff(string $hash1, string $hash2): void {
    $root = repoRoot();
    $commit1 = loadCommit($root, $hash1);
    $commit2 = loadCommit($root, $hash2);

    if ($commit1 === null || $commit2 === null) {
        echo "Invalid commit\n";
        exit(1);
    }

    $files1 = $commit1['files'];
    $files2 = $commit2['files'];

    $allFiles = array_unique(array_merge(array_keys($files1), array_keys($files2)));
    sort($allFiles);

    foreach ($allFiles as $file) {
        $in1 = array_key_exists($file, $files1);
        $in2 = array_key_exists($file, $files2);
        if ($in1 && $in2) {
            if ($files1[$file] !== $files2[$file]) {
                echo "Modified: $file\n";
            }
        } elseif (!$in1 && $in2) {
            echo "Added: $file\n";
        } elseif ($in1 && !$in2) {
            echo "Removed: $file\n";
        }
    }
    exit(0);
}

function cmdCheckout(string $hash): void {
    $root = repoRoot();
    $commit = loadCommit($root, $hash);
    if ($commit === null) {
        echo "Invalid commit\n";
        exit(1);
    }

    foreach ($commit['files'] as $filename => $blobHash) {
        $blobPath = $root . '/objects/' . $blobHash;
        $content = file_get_contents($blobPath);
        file_put_contents($filename, $content);
    }

    file_put_contents($root . '/HEAD', $hash);
    file_put_contents($root . '/index', '');
    echo "Checked out $hash\n";
    exit(0);
}

function cmdReset(string $hash): void {
    $root = repoRoot();
    $commit = loadCommit($root, $hash);
    if ($commit === null) {
        echo "Invalid commit\n";
        exit(1);
    }

    file_put_contents($root . '/HEAD', $hash);
    file_put_contents($root . '/index', '');
    echo "Reset to $hash\n";
    exit(0);
}

function cmdRm(string $file): void {
    $root = repoRoot();
    $raw = file_get_contents($root . '/index');
    $staged = array_values(array_filter(explode("\n", $raw)));

    if (!in_array($file, $staged, true)) {
        echo "File not in index\n";
        exit(1);
    }

    $newStaged = array_filter($staged, fn($f) => $f !== $file);
    $newContent = implode("\n", $newStaged);
    if ($newContent !== '') {
        $newContent .= "\n";
    }
    file_put_contents($root . '/index', $newContent);
    exit(0);
}

function cmdShow(string $hash): void {
    $root = repoRoot();
    $commit = loadCommit($root, $hash);
    if ($commit === null) {
        echo "Invalid commit\n";
        exit(1);
    }

    $files = $commit['files'];
    ksort($files);

    echo "commit $hash\n";
    echo "Date: {$commit['timestamp']}\n";
    echo "Message: {$commit['message']}\n";
    echo "Files:\n";
    foreach ($files as $filename => $blobHash) {
        echo "  $filename $blobHash\n";
    }
    exit(0);
}

// --- Entry point ---
$args = array_slice($argv, 1);

if (empty($args)) {
    fwrite(STDERR, "Usage: minigit <command>\n");
    exit(1);
}

switch ($args[0]) {
    case 'init':
        cmdInit();
        break;
    case 'add':
        if (!isset($args[1])) {
            fwrite(STDERR, "Usage: minigit add <file>\n");
            exit(1);
        }
        cmdAdd($args[1]);
        break;
    case 'commit':
        if (($args[1] ?? '') !== '-m' || !isset($args[2])) {
            fwrite(STDERR, "Usage: minigit commit -m <message>\n");
            exit(1);
        }
        cmdCommit($args[2]);
        break;
    case 'log':
        cmdLog();
        break;
    case 'status':
        cmdStatus();
        break;
    case 'diff':
        if (!isset($args[1]) || !isset($args[2])) {
            fwrite(STDERR, "Usage: minigit diff <commit1> <commit2>\n");
            exit(1);
        }
        cmdDiff($args[1], $args[2]);
        break;
    case 'checkout':
        if (!isset($args[1])) {
            fwrite(STDERR, "Usage: minigit checkout <commit_hash>\n");
            exit(1);
        }
        cmdCheckout($args[1]);
        break;
    case 'reset':
        if (!isset($args[1])) {
            fwrite(STDERR, "Usage: minigit reset <commit_hash>\n");
            exit(1);
        }
        cmdReset($args[1]);
        break;
    case 'rm':
        if (!isset($args[1])) {
            fwrite(STDERR, "Usage: minigit rm <file>\n");
            exit(1);
        }
        cmdRm($args[1]);
        break;
    case 'show':
        if (!isset($args[1])) {
            fwrite(STDERR, "Usage: minigit show <commit_hash>\n");
            exit(1);
        }
        cmdShow($args[1]);
        break;
    default:
        fwrite(STDERR, "Unknown command: {$args[0]}\n");
        exit(1);
}
