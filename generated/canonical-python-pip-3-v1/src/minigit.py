from __future__ import annotations

import os
import sys
import time


def minihash(data: bytes) -> str:
    h = 1469598103934665603
    for b in data:
        h ^= b
        h = (h * 1099511628211) % (2 ** 64)
    return format(h, '016x')


def find_repo() -> str:
    return os.path.join(os.getcwd(), '.minigit')


def cmd_init() -> int:
    repo = find_repo()
    if os.path.exists(repo):
        print("Repository already initialized")
        return 0
    os.makedirs(os.path.join(repo, 'objects'))
    os.makedirs(os.path.join(repo, 'commits'))
    open(os.path.join(repo, 'index'), 'w').close()
    open(os.path.join(repo, 'HEAD'), 'w').close()
    return 0


def cmd_add(filename: str) -> int:
    if not os.path.isfile(filename):
        print("File not found")
        return 1
    repo = find_repo()
    with open(filename, 'rb') as f:
        data = f.read()
    h = minihash(data)
    blob_path = os.path.join(repo, 'objects', h)
    with open(blob_path, 'wb') as f:
        f.write(data)
    index_path = os.path.join(repo, 'index')
    existing = []
    if os.path.exists(index_path):
        with open(index_path, 'r') as f:
            existing = [line.rstrip('\n') for line in f if line.strip()]
    if filename not in existing:
        with open(index_path, 'a') as f:
            f.write(filename + '\n')
    return 0


def cmd_commit(message: str) -> int:
    repo = find_repo()
    index_path = os.path.join(repo, 'index')
    staged = []
    if os.path.exists(index_path):
        with open(index_path, 'r') as f:
            staged = [line.rstrip('\n') for line in f if line.strip()]
    if not staged:
        print("Nothing to commit")
        return 1
    head_path = os.path.join(repo, 'HEAD')
    parent = 'NONE'
    if os.path.exists(head_path):
        with open(head_path, 'r') as f:
            val = f.read().strip()
        if val:
            parent = val
    timestamp = int(time.time())
    file_hashes = []
    for fname in sorted(staged):
        with open(fname, 'rb') as f:
            data = f.read()
        h = minihash(data)
        file_hashes.append((fname, h))
    lines = [
        f"parent: {parent}",
        f"timestamp: {timestamp}",
        f"message: {message}",
        "files:",
    ]
    for fname, h in file_hashes:
        lines.append(f"{fname} {h}")
    content = '\n'.join(lines) + '\n'
    commit_hash = minihash(content.encode())
    commit_path = os.path.join(repo, 'commits', commit_hash)
    with open(commit_path, 'w') as f:
        f.write(content)
    with open(head_path, 'w') as f:
        f.write(commit_hash)
    with open(index_path, 'w') as f:
        pass
    print(f"Committed {commit_hash}")
    return 0


def cmd_log() -> int:
    repo = find_repo()
    head_path = os.path.join(repo, 'HEAD')
    if not os.path.exists(head_path):
        print("No commits")
        return 0
    current = open(head_path).read().strip()
    if not current:
        print("No commits")
        return 0
    while current and current != 'NONE':
        commit_path = os.path.join(repo, 'commits', current)
        if not os.path.exists(commit_path):
            break
        with open(commit_path, 'r') as f:
            lines = f.read().splitlines()
        parent = 'NONE'
        timestamp = ''
        message = ''
        for line in lines:
            if line.startswith('parent: '):
                parent = line[len('parent: '):]
            elif line.startswith('timestamp: '):
                timestamp = line[len('timestamp: '):]
            elif line.startswith('message: '):
                message = line[len('message: '):]
        print(f"commit {current}")
        print(f"Date: {timestamp}")
        print(f"Message: {message}")
        print()
        if parent == 'NONE':
            break
        current = parent
    return 0


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print("Usage: minigit <command>", file=sys.stderr)
        return 1
    cmd = args[0]
    if cmd == 'init':
        return cmd_init()
    elif cmd == 'add':
        if len(args) < 2:
            print("Usage: minigit add <file>", file=sys.stderr)
            return 1
        return cmd_add(args[1])
    elif cmd == 'commit':
        if len(args) < 3 or args[1] != '-m':
            print("Usage: minigit commit -m <message>", file=sys.stderr)
            return 1
        return cmd_commit(args[2])
    elif cmd == 'log':
        return cmd_log()
    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
