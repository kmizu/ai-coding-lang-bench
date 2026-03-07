from __future__ import annotations

import os
import sys
import time


MINIGIT_DIR = ".minigit"
OBJECTS_DIR = os.path.join(MINIGIT_DIR, "objects")
COMMITS_DIR = os.path.join(MINIGIT_DIR, "commits")
INDEX_FILE = os.path.join(MINIGIT_DIR, "index")
HEAD_FILE = os.path.join(MINIGIT_DIR, "HEAD")


def minihash(data: bytes) -> str:
    h = 1469598103934665603
    for b in data:
        h ^= b
        h = (h * 1099511628211) % (2**64)
    return format(h, "016x")


def cmd_init() -> int:
    if os.path.exists(MINIGIT_DIR):
        print("Repository already initialized")
        return 0
    os.makedirs(OBJECTS_DIR)
    os.makedirs(COMMITS_DIR)
    open(INDEX_FILE, "w").close()
    open(HEAD_FILE, "w").close()
    return 0


def cmd_add(filename: str) -> int:
    if not os.path.isfile(filename):
        print("File not found")
        return 1
    data = open(filename, "rb").read()
    h = minihash(data)
    blob_path = os.path.join(OBJECTS_DIR, h)
    with open(blob_path, "wb") as f:
        f.write(data)
    staged = []
    if os.path.exists(INDEX_FILE):
        with open(INDEX_FILE, "r") as f:
            staged = [line.rstrip("\n") for line in f if line.strip()]
    if filename not in staged:
        with open(INDEX_FILE, "a") as f:
            f.write(filename + "\n")
    return 0


def cmd_commit(message: str) -> int:
    staged = []
    if os.path.exists(INDEX_FILE):
        with open(INDEX_FILE, "r") as f:
            staged = [line.rstrip("\n") for line in f if line.strip()]
    if not staged:
        print("Nothing to commit")
        return 1

    parent = ""
    if os.path.exists(HEAD_FILE):
        with open(HEAD_FILE, "r") as f:
            parent = f.read().strip()

    file_hashes = []
    for filename in sorted(staged):
        data = open(filename, "rb").read()
        h = minihash(data)
        file_hashes.append((filename, h))

    timestamp = int(time.time())
    parent_str = parent if parent else "NONE"

    lines = [
        f"parent: {parent_str}",
        f"timestamp: {timestamp}",
        f"message: {message}",
        "files:",
    ]
    for filename, h in file_hashes:
        lines.append(f"{filename} {h}")
    commit_content = "\n".join(lines) + "\n"

    commit_hash = minihash(commit_content.encode())
    commit_path = os.path.join(COMMITS_DIR, commit_hash)
    with open(commit_path, "w") as f:
        f.write(commit_content)

    with open(HEAD_FILE, "w") as f:
        f.write(commit_hash)

    open(INDEX_FILE, "w").close()

    print(f"Committed {commit_hash}")
    return 0


def cmd_log() -> int:
    if not os.path.exists(HEAD_FILE):
        print("No commits")
        return 0
    head = open(HEAD_FILE, "r").read().strip()
    if not head:
        print("No commits")
        return 0

    current = head
    while current and current != "NONE":
        commit_path = os.path.join(COMMITS_DIR, current)
        if not os.path.exists(commit_path):
            break
        with open(commit_path, "r") as f:
            content = f.read()

        parent = "NONE"
        timestamp = ""
        message = ""
        for line in content.splitlines():
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
        print("Usage: minigit <command> [args]", file=sys.stderr)
        return 1

    command = args[0]

    if command == "init":
        return cmd_init()
    elif command == "add":
        if len(args) < 2:
            print("Usage: minigit add <file>", file=sys.stderr)
            return 1
        return cmd_add(args[1])
    elif command == "commit":
        if len(args) < 3 or args[1] != "-m":
            print("Usage: minigit commit -m <message>", file=sys.stderr)
            return 1
        return cmd_commit(args[2])
    elif command == "log":
        return cmd_log()
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
