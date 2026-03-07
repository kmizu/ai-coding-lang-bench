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
        h = (h * 1099511628211) % (2 ** 64)
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


def read_index() -> list[str]:
    if not os.path.exists(INDEX_FILE):
        return []
    with open(INDEX_FILE, "r") as f:
        lines = [l.strip() for l in f.readlines()]
    return [l for l in lines if l]


def write_index(files: list[str]) -> None:
    with open(INDEX_FILE, "w") as f:
        for name in files:
            f.write(name + "\n")


def read_head() -> str:
    if not os.path.exists(HEAD_FILE):
        return ""
    with open(HEAD_FILE, "r") as f:
        return f.read().strip()


def write_head(h: str) -> None:
    with open(HEAD_FILE, "w") as f:
        f.write(h)


def cmd_add(filename: str) -> int:
    if not os.path.exists(filename):
        print("File not found")
        return 1
    with open(filename, "rb") as f:
        data = f.read()
    h = minihash(data)
    blob_path = os.path.join(OBJECTS_DIR, h)
    with open(blob_path, "wb") as f:
        f.write(data)
    staged = read_index()
    if filename not in staged:
        staged.append(filename)
        write_index(staged)
    return 0


def cmd_commit(message: str) -> int:
    staged = read_index()
    if not staged:
        print("Nothing to commit")
        return 1

    parent = read_head() or "NONE"
    timestamp = int(time.time())

    sorted_files = sorted(staged)
    file_lines = []
    for name in sorted_files:
        with open(name, "rb") as f:
            data = f.read()
        h = minihash(data)
        file_lines.append(f"{name} {h}")

    content = (
        f"parent: {parent}\n"
        f"timestamp: {timestamp}\n"
        f"message: {message}\n"
        f"files:\n"
        + "\n".join(file_lines)
        + "\n"
    )

    commit_hash = minihash(content.encode())
    commit_path = os.path.join(COMMITS_DIR, commit_hash)
    with open(commit_path, "w") as f:
        f.write(content)

    write_head(commit_hash)
    write_index([])
    print(f"Committed {commit_hash}")
    return 0


def cmd_log() -> int:
    head = read_head()
    if not head:
        print("No commits")
        return 0

    current = head
    while current and current != "NONE":
        commit_path = os.path.join(COMMITS_DIR, current)
        if not os.path.exists(commit_path):
            break
        with open(commit_path, "r") as f:
            lines = f.read().splitlines()

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
