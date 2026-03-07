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


def parse_commit(commit_hash: str) -> dict | None:
    commit_path = os.path.join(COMMITS_DIR, commit_hash)
    if not os.path.exists(commit_path):
        return None
    with open(commit_path, "r") as f:
        content = f.read()
    result: dict = {"parent": "NONE", "timestamp": "", "message": "", "files": {}}
    in_files = False
    for line in content.splitlines():
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
    staged = []
    if os.path.exists(INDEX_FILE):
        with open(INDEX_FILE, "r") as f:
            staged = [line.rstrip("\n") for line in f if line.strip()]
    print("Staged files:")
    if staged:
        for f in staged:
            print(f)
    else:
        print("(none)")
    return 0


def cmd_diff(commit1: str, commit2: str) -> int:
    c1 = parse_commit(commit1)
    if c1 is None:
        print("Invalid commit")
        return 1
    c2 = parse_commit(commit2)
    if c2 is None:
        print("Invalid commit")
        return 1

    files1 = c1["files"]
    files2 = c2["files"]
    all_files = sorted(set(files1) | set(files2))

    for fname in all_files:
        if fname in files1 and fname not in files2:
            print(f"Removed: {fname}")
        elif fname not in files1 and fname in files2:
            print(f"Added: {fname}")
        elif files1[fname] != files2[fname]:
            print(f"Modified: {fname}")
    return 0


def cmd_checkout(commit_hash: str) -> int:
    commit = parse_commit(commit_hash)
    if commit is None:
        print("Invalid commit")
        return 1

    for filename, blob_hash in commit["files"].items():
        blob_path = os.path.join(OBJECTS_DIR, blob_hash)
        with open(blob_path, "rb") as f:
            data = f.read()
        dirpath = os.path.dirname(filename)
        if dirpath:
            os.makedirs(dirpath, exist_ok=True)
        with open(filename, "wb") as f:
            f.write(data)

    with open(HEAD_FILE, "w") as f:
        f.write(commit_hash)
    open(INDEX_FILE, "w").close()

    print(f"Checked out {commit_hash}")
    return 0


def cmd_reset(commit_hash: str) -> int:
    if not os.path.exists(os.path.join(COMMITS_DIR, commit_hash)):
        print("Invalid commit")
        return 1

    with open(HEAD_FILE, "w") as f:
        f.write(commit_hash)
    open(INDEX_FILE, "w").close()

    print(f"Reset to {commit_hash}")
    return 0


def cmd_rm(filename: str) -> int:
    staged = []
    if os.path.exists(INDEX_FILE):
        with open(INDEX_FILE, "r") as f:
            staged = [line.rstrip("\n") for line in f if line.strip()]
    if filename not in staged:
        print("File not in index")
        return 1
    staged = [f for f in staged if f != filename]
    with open(INDEX_FILE, "w") as f:
        for name in staged:
            f.write(name + "\n")
    return 0


def cmd_show(commit_hash: str) -> int:
    commit = parse_commit(commit_hash)
    if commit is None:
        print("Invalid commit")
        return 1

    print(f"commit {commit_hash}")
    print(f"Date: {commit['timestamp']}")
    print(f"Message: {commit['message']}")
    print("Files:")
    for fname in sorted(commit["files"]):
        print(f"  {fname} {commit['files'][fname]}")
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
    elif command == "status":
        return cmd_status()
    elif command == "diff":
        if len(args) < 3:
            print("Usage: minigit diff <commit1> <commit2>", file=sys.stderr)
            return 1
        return cmd_diff(args[1], args[2])
    elif command == "checkout":
        if len(args) < 2:
            print("Usage: minigit checkout <commit_hash>", file=sys.stderr)
            return 1
        return cmd_checkout(args[1])
    elif command == "reset":
        if len(args) < 2:
            print("Usage: minigit reset <commit_hash>", file=sys.stderr)
            return 1
        return cmd_reset(args[1])
    elif command == "rm":
        if len(args) < 2:
            print("Usage: minigit rm <file>", file=sys.stderr)
            return 1
        return cmd_rm(args[1])
    elif command == "show":
        if len(args) < 2:
            print("Usage: minigit show <commit_hash>", file=sys.stderr)
            return 1
        return cmd_show(args[1])
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
