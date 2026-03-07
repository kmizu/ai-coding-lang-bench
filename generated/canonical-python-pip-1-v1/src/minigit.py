from __future__ import annotations

import os
import sys
import time


def minihash(data: bytes) -> str:
    h = 1469598103934665603
    for b in data:
        h ^= b
        h = (h * 1099511628211) % (2**64)
    return format(h, '016x')


def repo_root() -> str:
    return ".minigit"


def cmd_init() -> int:
    root = repo_root()
    if os.path.exists(root):
        print("Repository already initialized")
        return 0
    os.makedirs(os.path.join(root, "objects"))
    os.makedirs(os.path.join(root, "commits"))
    open(os.path.join(root, "index"), "w").close()
    open(os.path.join(root, "HEAD"), "w").close()
    return 0


def cmd_add(filename: str) -> int:
    if not os.path.isfile(filename):
        print("File not found")
        return 1
    data = open(filename, "rb").read()
    h = minihash(data)
    blob_path = os.path.join(repo_root(), "objects", h)
    with open(blob_path, "wb") as f:
        f.write(data)
    index_path = os.path.join(repo_root(), "index")
    existing = open(index_path).read().splitlines()
    if filename not in existing:
        with open(index_path, "a") as f:
            f.write(filename + "\n")
    return 0


def cmd_commit(message: str) -> int:
    root = repo_root()
    index_path = os.path.join(root, "index")
    staged = [l for l in open(index_path).read().splitlines() if l]
    if not staged:
        print("Nothing to commit")
        return 1
    head_path = os.path.join(root, "HEAD")
    parent = open(head_path).read().strip() or "NONE"
    timestamp = int(time.time())
    files_sorted = sorted(staged)
    file_hashes = []
    for fname in files_sorted:
        data = open(fname, "rb").read()
        h = minihash(data)
        file_hashes.append((fname, h))
    files_lines = "\n".join(f"{fname} {h}" for fname, h in file_hashes)
    commit_content = (
        f"parent: {parent}\n"
        f"timestamp: {timestamp}\n"
        f"message: {message}\n"
        f"files:\n"
        f"{files_lines}\n"
    )
    commit_bytes = commit_content.encode()
    commit_hash = minihash(commit_bytes)
    commit_path = os.path.join(root, "commits", commit_hash)
    with open(commit_path, "w") as f:
        f.write(commit_content)
    with open(head_path, "w") as f:
        f.write(commit_hash)
    open(index_path, "w").close()
    print(f"Committed {commit_hash}")
    return 0


def cmd_log() -> int:
    root = repo_root()
    head = open(os.path.join(root, "HEAD")).read().strip()
    if not head:
        print("No commits")
        return 0
    current = head
    while current and current != "NONE":
        commit_path = os.path.join(root, "commits", current)
        content = open(commit_path).read()
        lines = content.splitlines()
        parent = ""
        timestamp = ""
        message = ""
        for line in lines:
            if line.startswith("parent: "):
                parent = line[len("parent: "):]
            elif line.startswith("timestamp: "):
                timestamp = line[len("timestamp: "):]
            elif line.startswith("message: "):
                message = line[len("message: "):]
        print(f"commit {current}")
        print(f"Date: {timestamp}")
        print(f"Message: {message}")
        print()
        if parent == "NONE":
            break
        current = parent
    return 0


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print("Usage: minigit <command>", file=sys.stderr)
        return 1
    cmd = args[0]
    if cmd == "init":
        return cmd_init()
    elif cmd == "add":
        if len(args) < 2:
            print("Usage: minigit add <file>", file=sys.stderr)
            return 1
        return cmd_add(args[1])
    elif cmd == "commit":
        if len(args) < 3 or args[1] != "-m":
            print("Usage: minigit commit -m <message>", file=sys.stderr)
            return 1
        return cmd_commit(args[2])
    elif cmd == "log":
        return cmd_log()
    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
