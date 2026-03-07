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
    default:
        fwrite(STDERR, "Unknown command: {$args[0]}\n");
        exit(1);
}
