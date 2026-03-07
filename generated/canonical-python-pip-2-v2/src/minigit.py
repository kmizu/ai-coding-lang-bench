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


def parse_commit(commit_hash: str) -> dict:
    commit_path = os.path.join(COMMITS_DIR, commit_hash)
    if not os.path.exists(commit_path):
        return {}
    with open(commit_path, "r") as f:
        content = f.read()
    lines = content.splitlines()
    result: dict = {"parent": "", "timestamp": "", "message": "", "files": {}}
    in_files = False
    for line in lines:
        if in_files:
            parts = line.split(" ", 1)
            if len(parts) == 2:
                result["files"][parts[0]] = parts[1]
        elif line.startswith("parent: "):
            result["parent"] = line[len("parent: "):]
        elif line.startswith("timestamp: "):
            result["timestamp"] = line[len("timestamp: "):]
        elif line.startswith("message: "):
            result["message"] = line[len("message: "):]
        elif line == "files:":
            in_files = True
    return result


def cmd_status() -> int:
    staged = read_index()
    print("Staged files:")
    if staged:
        for name in staged:
            print(name)
    else:
        print("(none)")
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
        info = parse_commit(current)
        print(f"commit {current}")
        print(f"Date: {info['timestamp']}")
        print(f"Message: {info['message']}")
        print()
        if info["parent"] == "NONE":
            break
        current = info["parent"]

    return 0


def cmd_diff(hash1: str, hash2: str) -> int:
    if not os.path.exists(os.path.join(COMMITS_DIR, hash1)) or \
       not os.path.exists(os.path.join(COMMITS_DIR, hash2)):
        print("Invalid commit")
        return 1
    files1 = parse_commit(hash1)["files"]
    files2 = parse_commit(hash2)["files"]
    all_files = sorted(set(files1) | set(files2))
    for name in all_files:
        if name in files1 and name not in files2:
            print(f"Removed: {name}")
        elif name not in files1 and name in files2:
            print(f"Added: {name}")
        elif files1[name] != files2[name]:
            print(f"Modified: {name}")
    return 0


def cmd_checkout(commit_hash: str) -> int:
    if not os.path.exists(os.path.join(COMMITS_DIR, commit_hash)):
        print("Invalid commit")
        return 1
    info = parse_commit(commit_hash)
    for name, blob_hash in info["files"].items():
        blob_path = os.path.join(OBJECTS_DIR, blob_hash)
        with open(blob_path, "rb") as f:
            data = f.read()
        with open(name, "wb") as f:
            f.write(data)
    write_head(commit_hash)
    write_index([])
    print(f"Checked out {commit_hash}")
    return 0


def cmd_reset(commit_hash: str) -> int:
    if not os.path.exists(os.path.join(COMMITS_DIR, commit_hash)):
        print("Invalid commit")
        return 1
    write_head(commit_hash)
    write_index([])
    print(f"Reset to {commit_hash}")
    return 0


def cmd_rm(filename: str) -> int:
    staged = read_index()
    if filename not in staged:
        print("File not in index")
        return 1
    staged.remove(filename)
    write_index(staged)
    return 0


def cmd_show(commit_hash: str) -> int:
    if not os.path.exists(os.path.join(COMMITS_DIR, commit_hash)):
        print("Invalid commit")
        return 1
    info = parse_commit(commit_hash)
    print(f"commit {commit_hash}")
    print(f"Date: {info['timestamp']}")
    print(f"Message: {info['message']}")
    print("Files:")
    for name in sorted(info["files"]):
        print(f"  {name} {info['files'][name]}")
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
    elif cmd == "status":
        return cmd_status()
    elif cmd == "log":
        return cmd_log()
    elif cmd == "diff":
        if len(args) < 3:
            print("Usage: minigit diff <commit1> <commit2>", file=sys.stderr)
            return 1
        return cmd_diff(args[1], args[2])
    elif cmd == "checkout":
        if len(args) < 2:
            print("Usage: minigit checkout <commit_hash>", file=sys.stderr)
            return 1
        return cmd_checkout(args[1])
    elif cmd == "reset":
        if len(args) < 2:
            print("Usage: minigit reset <commit_hash>", file=sys.stderr)
            return 1
        return cmd_reset(args[1])
    elif cmd == "rm":
        if len(args) < 2:
            print("Usage: minigit rm <file>", file=sys.stderr)
            return 1
        return cmd_rm(args[1])
    elif cmd == "show":
        if len(args) < 2:
            print("Usage: minigit show <commit_hash>", file=sys.stderr)
            return 1
        return cmd_show(args[1])
    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
