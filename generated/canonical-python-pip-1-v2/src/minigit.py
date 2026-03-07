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


def cmd_status() -> int:
    root = repo_root()
    index_path = os.path.join(root, "index")
    staged = [l for l in open(index_path).read().splitlines() if l]
    print("Staged files:")
    if staged:
        for f in staged:
            print(f)
    else:
        print("(none)")
    return 0


def parse_commit(commit_hash: str) -> dict | None:
    root = repo_root()
    commit_path = os.path.join(root, "commits", commit_hash)
    if not os.path.isfile(commit_path):
        return None
    content = open(commit_path).read()
    lines = content.splitlines()
    result: dict = {"parent": "", "timestamp": "", "message": "", "files": {}}
    in_files = False
    for line in lines:
        if in_files:
            if line:
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


def cmd_diff(commit1: str, commit2: str) -> int:
    c1 = parse_commit(commit1)
    c2 = parse_commit(commit2)
    if c1 is None or c2 is None:
        print("Invalid commit")
        return 1
    files1 = c1["files"]
    files2 = c2["files"]
    all_files = sorted(set(files1.keys()) | set(files2.keys()))
    for f in all_files:
        if f in files1 and f not in files2:
            print(f"Removed: {f}")
        elif f not in files1 and f in files2:
            print(f"Added: {f}")
        elif files1[f] != files2[f]:
            print(f"Modified: {f}")
    return 0


def cmd_checkout(commit_hash: str) -> int:
    root = repo_root()
    c = parse_commit(commit_hash)
    if c is None:
        print("Invalid commit")
        return 1
    for fname, blob_hash in c["files"].items():
        blob_path = os.path.join(root, "objects", blob_hash)
        data = open(blob_path, "rb").read()
        with open(fname, "wb") as f:
            f.write(data)
    with open(os.path.join(root, "HEAD"), "w") as f:
        f.write(commit_hash)
    open(os.path.join(root, "index"), "w").close()
    print(f"Checked out {commit_hash}")
    return 0


def cmd_reset(commit_hash: str) -> int:
    root = repo_root()
    c = parse_commit(commit_hash)
    if c is None:
        print("Invalid commit")
        return 1
    with open(os.path.join(root, "HEAD"), "w") as f:
        f.write(commit_hash)
    open(os.path.join(root, "index"), "w").close()
    print(f"Reset to {commit_hash}")
    return 0


def cmd_rm(filename: str) -> int:
    root = repo_root()
    index_path = os.path.join(root, "index")
    staged = [l for l in open(index_path).read().splitlines() if l]
    if filename not in staged:
        print("File not in index")
        return 1
    staged.remove(filename)
    with open(index_path, "w") as f:
        for entry in staged:
            f.write(entry + "\n")
    return 0


def cmd_show(commit_hash: str) -> int:
    root = repo_root()
    c = parse_commit(commit_hash)
    if c is None:
        print("Invalid commit")
        return 1
    print(f"commit {commit_hash}")
    print(f"Date: {c['timestamp']}")
    print(f"Message: {c['message']}")
    print("Files:")
    for fname in sorted(c["files"].keys()):
        print(f"  {fname} {c['files'][fname]}")
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
    elif cmd == "status":
        return cmd_status()
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
