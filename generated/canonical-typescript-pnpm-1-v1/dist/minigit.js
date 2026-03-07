import * as fs from "fs";
import * as path from "path";
const MINIGIT_DIR = ".minigit";
const OBJECTS_DIR = path.join(MINIGIT_DIR, "objects");
const COMMITS_DIR = path.join(MINIGIT_DIR, "commits");
const INDEX_FILE = path.join(MINIGIT_DIR, "index");
const HEAD_FILE = path.join(MINIGIT_DIR, "HEAD");
const MOD64 = 2n ** 64n;
function miniHash(data) {
    let h = 1469598103934665603n;
    for (const b of data) {
        h = (h ^ BigInt(b)) * 1099511628211n % MOD64;
    }
    return h.toString(16).padStart(16, "0");
}
function cmdInit() {
    if (fs.existsSync(MINIGIT_DIR)) {
        console.log("Repository already initialized");
        return 0;
    }
    fs.mkdirSync(OBJECTS_DIR, { recursive: true });
    fs.mkdirSync(COMMITS_DIR, { recursive: true });
    fs.writeFileSync(INDEX_FILE, "");
    fs.writeFileSync(HEAD_FILE, "");
    return 0;
}
function cmdAdd(file) {
    if (!fs.existsSync(file)) {
        console.log("File not found");
        return 1;
    }
    const content = fs.readFileSync(file);
    const hash = miniHash(content);
    fs.writeFileSync(path.join(OBJECTS_DIR, hash), content);
    const indexContent = fs.readFileSync(INDEX_FILE, "utf8");
    const staged = indexContent.split("\n").filter(Boolean);
    if (!staged.includes(file)) {
        staged.push(file);
        fs.writeFileSync(INDEX_FILE, staged.join("\n") + "\n");
    }
    return 0;
}
function cmdCommit(message) {
    const indexContent = fs.readFileSync(INDEX_FILE, "utf8");
    const staged = indexContent.split("\n").filter(Boolean);
    if (staged.length === 0) {
        console.log("Nothing to commit");
        return 1;
    }
    const head = fs.readFileSync(HEAD_FILE, "utf8").trim();
    const parent = head || "NONE";
    const timestamp = Math.floor(Date.now() / 1000);
    const sortedFiles = [...staged].sort();
    const fileLines = sortedFiles.map((f) => {
        const hash = miniHash(fs.readFileSync(f));
        return `${f} ${hash}`;
    });
    const commitContent = `parent: ${parent}\n` +
        `timestamp: ${timestamp}\n` +
        `message: ${message}\n` +
        `files:\n` +
        fileLines.join("\n") + "\n";
    const commitHash = miniHash(Buffer.from(commitContent));
    fs.writeFileSync(path.join(COMMITS_DIR, commitHash), commitContent);
    fs.writeFileSync(HEAD_FILE, commitHash);
    fs.writeFileSync(INDEX_FILE, "");
    console.log(`Committed ${commitHash}`);
    return 0;
}
function cmdLog() {
    const head = fs.readFileSync(HEAD_FILE, "utf8").trim();
    if (!head) {
        console.log("No commits");
        return 0;
    }
    let current = head;
    while (current && current !== "NONE") {
        const commitPath = path.join(COMMITS_DIR, current);
        if (!fs.existsSync(commitPath))
            break;
        const content = fs.readFileSync(commitPath, "utf8");
        const lines = content.split("\n");
        let parentHash = "NONE";
        let timestamp = "";
        let message = "";
        for (const line of lines) {
            if (line.startsWith("parent: "))
                parentHash = line.slice("parent: ".length);
            else if (line.startsWith("timestamp: "))
                timestamp = line.slice("timestamp: ".length);
            else if (line.startsWith("message: "))
                message = line.slice("message: ".length);
        }
        console.log(`commit ${current}`);
        console.log(`Date: ${timestamp}`);
        console.log(`Message: ${message}`);
        console.log();
        current = parentHash === "NONE" ? "" : parentHash;
    }
    return 0;
}
function main() {
    const args = process.argv.slice(2);
    if (args.length === 0) {
        console.error("Usage: minigit <command> [args]");
        return 1;
    }
    const command = args[0];
    if (command === "init") {
        return cmdInit();
    }
    if (command === "add") {
        if (args.length < 2) {
            console.error("Usage: minigit add <file>");
            return 1;
        }
        return cmdAdd(args[1]);
    }
    if (command === "commit") {
        if (args.length < 3 || args[1] !== "-m") {
            console.error('Usage: minigit commit -m "<message>"');
            return 1;
        }
        return cmdCommit(args[2]);
    }
    if (command === "log") {
        return cmdLog();
    }
    console.error(`Unknown command: ${command}`);
    return 1;
}
process.exit(main());
