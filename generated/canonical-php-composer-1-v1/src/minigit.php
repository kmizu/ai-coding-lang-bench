<?php
declare(strict_types=1);

/**
 * Multiply two 64-bit integers and return low 64 bits (as signed PHP int).
 * Uses 16-bit chunk decomposition to avoid PHP integer overflow.
 */
function mul64(int $a, int $b): int {
    // Split a into four 16-bit chunks (arithmetic right shift, then mask)
    $a0 = $a & 0xFFFF;
    $a1 = ($a >> 16) & 0xFFFF;
    $a2 = ($a >> 32) & 0xFFFF;
    $a3 = ($a >> 48) & 0xFFFF;

    // b = 1099511628211; each a_i is <= 0xFFFF, so a_i * b < 2^57 — fits in PHP int
    $p0 = $a0 * $b;
    $p1 = $a1 * $b;
    $p2 = $a2 * $b;
    $p3 = $a3 * $b;

    // Accumulate 16 bits at a time with carry propagation
    $r0 = $p0 & 0xFFFF; $c = $p0 >> 16;
    $s1 = $p1 + $c; $r1 = $s1 & 0xFFFF; $c = $s1 >> 16;
    $s2 = $p2 + $c; $r2 = $s2 & 0xFFFF; $c = $s2 >> 16;
    $s3 = $p3 + $c; $r3 = $s3 & 0xFFFF;
    // bits above 64 are discarded (mod 2^64)

    $lo = $r0 + $r1 * 0x10000;
    $hi = $r2 + $r3 * 0x10000;

    // Reconstruct as signed 64-bit PHP int
    if ($hi >= 0x80000000) {
        // High bit set → negative in two's complement
        return ($hi - 0x100000000) * 0x100000000 + $lo;
    }
    return $hi * 0x100000000 + $lo;
}

/**
 * MiniHash: FNV-1a variant, 64-bit, 16-char hex output.
 */
function minihash(string $data): string {
    $h = 1469598103934665603; // FNV offset basis
    $len = strlen($data);
    for ($i = 0; $i < $len; $i++) {
        $h ^= ord($data[$i]);
        $h = mul64($h, 1099511628211);
    }
    // sprintf '%016x' formats signed int as unsigned hex on 64-bit PHP
    return sprintf('%016x', $h);
}

function repo_path(): string {
    return getcwd() . '/.minigit';
}

function cmd_init(): void {
    $repo = repo_path();
    if (is_dir($repo)) {
        echo "Repository already initialized\n";
        exit(0);
    }
    mkdir($repo . '/objects', 0755, true);
    mkdir($repo . '/commits', 0755, true);
    file_put_contents($repo . '/index', '');
    file_put_contents($repo . '/HEAD', '');
}

function cmd_add(string $file): void {
    $repo = repo_path();
    if (!file_exists($file)) {
        echo "File not found\n";
        exit(1);
    }
    $content = file_get_contents($file);
    $hash = minihash($content);
    file_put_contents($repo . '/objects/' . $hash, $content);

    $index_path = $repo . '/index';
    $raw = file_get_contents($index_path);
    $entries = ($raw === '') ? [] : array_filter(explode("\n", $raw), fn($l) => $l !== '');
    if (!in_array($file, $entries, true)) {
        $entries[] = $file;
        file_put_contents($index_path, implode("\n", array_values($entries)) . "\n");
    }
}

function cmd_commit(string $message): void {
    $repo = repo_path();
    $index_path = $repo . '/index';
    $raw = file_get_contents($index_path);
    $entries = array_filter(explode("\n", $raw), fn($l) => $l !== '');

    if (empty($entries)) {
        echo "Nothing to commit\n";
        exit(1);
    }

    sort($entries);

    $head = trim(file_get_contents($repo . '/HEAD'));
    $parent = ($head === '') ? 'NONE' : $head;
    $timestamp = time();

    $files_block = '';
    foreach ($entries as $fname) {
        $hash = minihash(file_get_contents($fname));
        $files_block .= $fname . ' ' . $hash . "\n";
    }

    $commit_content = "parent: {$parent}\ntimestamp: {$timestamp}\nmessage: {$message}\nfiles:\n{$files_block}";
    $commit_hash = minihash($commit_content);

    file_put_contents($repo . '/commits/' . $commit_hash, $commit_content);
    file_put_contents($repo . '/HEAD', $commit_hash);
    file_put_contents($index_path, '');

    echo "Committed {$commit_hash}\n";
}

function cmd_log(): void {
    $repo = repo_path();
    $head = trim(file_get_contents($repo . '/HEAD'));

    if ($head === '') {
        echo "No commits\n";
        return;
    }

    $hash = $head;
    while ($hash !== '' && $hash !== 'NONE') {
        $path = $repo . '/commits/' . $hash;
        if (!file_exists($path)) break;

        $lines = explode("\n", file_get_contents($path));
        $parent = $timestamp = $message = '';
        foreach ($lines as $line) {
            if (str_starts_with($line, 'parent: '))    $parent    = substr($line, 8);
            elseif (str_starts_with($line, 'timestamp: ')) $timestamp = substr($line, 11);
            elseif (str_starts_with($line, 'message: '))  $message   = substr($line, 9);
        }

        echo "commit {$hash}\n";
        echo "Date: {$timestamp}\n";
        echo "Message: {$message}\n";
        echo "\n";

        $hash = ($parent === 'NONE') ? '' : $parent;
    }
}

// ── Entry point ──────────────────────────────────────────────────────────────

$args = array_slice($argv, 1);

if (empty($args)) {
    fwrite(STDERR, "Usage: minigit <command>\n");
    exit(1);
}

$cmd = array_shift($args);

switch ($cmd) {
    case 'init':
        cmd_init();
        break;
    case 'add':
        if (empty($args)) { fwrite(STDERR, "Usage: minigit add <file>\n"); exit(1); }
        cmd_add($args[0]);
        break;
    case 'commit':
        if (count($args) < 2 || $args[0] !== '-m') {
            fwrite(STDERR, "Usage: minigit commit -m <message>\n");
            exit(1);
        }
        cmd_commit($args[1]);
        break;
    case 'log':
        cmd_log();
        break;
    default:
        fwrite(STDERR, "Unknown command: {$cmd}\n");
        exit(1);
}
