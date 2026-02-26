import Foundation

// MARK: - Terminal Command & Output Model

struct TerminalCommand {
    let prompt: String  // e.g. "user@hostname:~/project$"
    let command: String
    let output: [String]  // Lines of output
}

struct TerminalSession {
    let title: String
    let commands: [TerminalCommand]
}

// MARK: - Command Database

class CommandDatabase {

    // MARK: - Random helpers
    private static func rand(_ arr: [String]) -> String { arr.randomElement()! }

    private static let usernames = [
        "dev", "root", "admin", "alice", "bob", "charlie", "system", "yemzikk",
    ]
    private static let hostnames = [
        "macbook-pro", "dev-server", "prod-01", "build-machine", "localhost", "arch-btw",
    ]
    private static let paths = [
        "~/projects/app", "~/dev/backend", "~/code/frontend", "~/work/api",
        "~/repos/service", "~/src/platform", "/opt/server", "~/projects/ml-model",
    ]

    static func randomPrompt() -> String {
        let user = rand(usernames)
        let host = rand(hostnames)
        let path = rand(paths)
        let symbol = user == "root" ? "#" : "$"
        return "\(user)@\(host):\(path)\(symbol)"
    }

    // MARK: - All Command Categories

    static func randomSession() -> TerminalSession {
        // Occasionally surface an easter egg session; otherwise pick from the normal pool.
        if let egg = EasterEggs.randomEasterEggSession() { return egg }
        let sessions: [() -> TerminalSession] = [
            gitSession, dockerSession, npmSession, pythonSession,
            systemSession, kubernetesSession, sshSession,
            buildSession, databaseSession, networkSession,
            fileSession, processSession, rustSession, awsSession,
        ]
        return sessions.randomElement()!()
    }

    // MARK: - Git Session
    static func gitSession() -> TerminalSession {
        let repo = rand([
            "webapp", "api-service", "mobile-app", "platform", "data-pipeline", "infra",
        ])
        let branch = rand(["main", "develop", "feature/auth", "fix/memory-leak", "release/2.1.0"])
        let hash1 = String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
        let hash2 = String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
        let hash3 = String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
        let files = [
            "src/auth.ts", "components/Button.tsx", "api/routes.py", "config.yml", "README.md",
            "tests/unit.spec.ts", "Dockerfile", "package.json", "src/utils/parser.go",
        ]
        let f1 = rand(files)
        let f2 = rand(files)
        let f3 = rand(files)
        let msgs = [
            "fix: resolve null pointer exception in auth",
            "feat: add OAuth2 support",
            "refactor: extract service layer",
            "chore: update dependencies",
            "docs: update API documentation",
            "perf: optimize database queries",
            "test: add integration tests",
            "ci: configure GitHub Actions",
        ]
        let m1 = rand(msgs)
        let m2 = rand(msgs)
        let m3 = rand(msgs)
        let user = rand(["alice", "bob", "charlie", "dev"])

        return TerminalSession(
            title: "git — \(repo)",
            commands: [
                TerminalCommand(
                    prompt: "\(user)@laptop:~/\(repo)$", command: "git status",
                    output: [
                        "On branch \(branch)",
                        "Your branch is up to date with 'origin/\(branch)'.",
                        "",
                        "Changes not staged for commit:",
                        "  (use \"git add <file>...\" to update what will be committed)",
                        "",
                        "\t\u{1B}[31mmodified:   \(f1)\u{1B}[0m",
                        "\t\u{1B}[31mmodified:   \(f2)\u{1B}[0m",
                        "",
                        "Untracked files:",
                        "\t\u{1B}[31m\(f3)\u{1B}[0m",
                        "",
                        "no changes added to commit (use \"git add\" and/or \"git commit -a\")",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@laptop:~/\(repo)$", command: "git log --oneline -8",
                    output: [
                        "\(hash1) (\u{1B}[33mHEAD -> \(branch)\u{1B}[0m, \u{1B}[32morigin/\(branch)\u{1B}[0m) \(m1)",
                        "\(hash2) \(m2)",
                        "\(hash3) \(m3)",
                        String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
                            + " chore: bump version to \(Int.random(in: 1...3)).\(Int.random(in: 0...9)).\(Int.random(in: 0...20))",
                        String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
                            + " fix: correct type annotation",
                        String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
                            + " Merge branch 'develop' into main",
                        String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
                            + " feat: implement caching layer",
                        String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
                            + " initial commit",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@laptop:~/\(repo)$", command: "git diff --stat HEAD~1",
                    output: [
                        " \(f1) | \(Int.random(in: 5...80)) \(String(repeating: "+", count: Int.random(in: 3...15)))\(String(repeating: "-", count: Int.random(in: 0...5)))",
                        " \(f2) | \(Int.random(in: 2...40)) \(String(repeating: "+", count: Int.random(in: 1...10)))\(String(repeating: "-", count: Int.random(in: 0...8)))",
                        " \(Int.random(in: 2...5)) files changed, \(Int.random(in: 10...200)) insertions(+), \(Int.random(in: 0...50)) deletions(-)",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@laptop:~/\(repo)$", command: "git stash list",
                    output: [
                        "stash@{0}: WIP on \(branch): \(hash1) \(m1)",
                        "stash@{1}: On feature/old-work: \(hash2) \(m2)",
                    ]),
            ])
    }

    // MARK: - Docker Session
    static func dockerSession() -> TerminalSession {
        let app = rand(["webapp", "api", "worker", "nginx", "postgres", "redis"])
        let imgTag = "\(Int.random(in: 1...3)).\(Int.random(in: 0...12)).\(Int.random(in: 0...20))"
        let containerID = String(
            format: "%012x", Int.random(in: 0x1000_0000_0000...0xFFFF_FFFF_FFFF))
        let shortID = String(containerID.prefix(12))
        let imageID = String(format: "%12x", Int.random(in: 0x1000_0000_0000...0xFFFF_FFFF_FFFF))
        let port = rand(["3000", "8080", "8000", "5000", "4000"])

        return TerminalSession(
            title: "docker — \(app)",
            commands: [
                TerminalCommand(
                    prompt: "dev@server:~/\(app)$", command: "docker ps",
                    output: [
                        "CONTAINER ID   IMAGE              COMMAND                  CREATED         STATUS         PORTS                    NAMES",
                        "\(shortID)   \(app):\(imgTag)      \"/bin/sh -c 'node s…\"   2 hours ago     Up 2 hours     0.0.0.0:\(port)->\(port)/tcp   \(app)_1",
                        String(format: "%012x", Int.random(in: 0x1000_0000_0000...0xFFFF_FFFF_FFFF))
                            .prefix(12)
                            + "   postgres:15          \"docker-entrypoint.s…\"   2 hours ago     Up 2 hours     5432/tcp                 db_1",
                        String(format: "%012x", Int.random(in: 0x1000_0000_0000...0xFFFF_FFFF_FFFF))
                            .prefix(12)
                            + "   redis:7.0            \"docker-entrypoint.s…\"   2 hours ago     Up 2 hours     6379/tcp                 cache_1",
                    ]),
                TerminalCommand(
                    prompt: "dev@server:~/\(app)$", command: "docker build -t \(app):\(imgTag) .",
                    output: [
                        "[+] Building \(Int.random(in: 15...120)).0s (12/12) FINISHED",
                        " => [internal] load build definition from Dockerfile",
                        " => [internal] load .dockerignore",
                        " => [internal] load metadata for docker.io/library/node:18-alpine",
                        " => [1/7] FROM docker.io/library/node:18-alpine",
                        " => [2/7] WORKDIR /app",
                        " => [3/7] COPY package*.json ./",
                        " => [4/7] RUN npm ci --only=production",
                        " => [5/7] COPY . .",
                        " => [6/7] RUN npm run build",
                        " => [7/7] EXPOSE \(port)",
                        " => exporting to image",
                        " => => writing image sha256:\(imageID)",
                        " => => naming to docker.io/library/\(app):\(imgTag)",
                        "",
                        "Successfully built \(imageID.prefix(12))",
                        "Successfully tagged \(app):\(imgTag)",
                    ]),
                TerminalCommand(
                    prompt: "dev@server:~/\(app)$", command: "docker logs \(shortID) --tail 20",
                    output: [
                        "[\(rand(["INFO", "INFO", "INFO", "WARN"]))] Server starting on port \(port)",
                        "[INFO] Database connection established",
                        "[INFO] Cache connection established",
                        "[INFO] Loading configuration from /app/config.yml",
                        "[INFO] Registered \(Int.random(in: 10...50)) routes",
                        "[INFO] Server ready in \(Int.random(in: 200...3000))ms",
                        "[INFO] GET /health 200 \(Int.random(in: 1...15))ms",
                        "[INFO] POST /api/auth/login 200 \(Int.random(in: 20...80))ms",
                        "[INFO] GET /api/users 200 \(Int.random(in: 5...30))ms",
                        "[INFO] Worker process spawned (pid: \(Int.random(in: 1000...9999)))",
                    ]),
            ])
    }

    // MARK: - NPM/Node Session
    static func npmSession() -> TerminalSession {
        let project = rand(["frontend", "dashboard", "mobile-web", "landing-page", "admin-panel"])
        let dur = "\(Int.random(in: 10...120)).\(Int.random(in: 0...9))s"
        let pkgCount = Int.random(in: 200...1200)
        let version = "\(Int.random(in: 1...5)).\(Int.random(in: 0...15)).\(Int.random(in: 0...10))"

        return TerminalSession(
            title: "npm — \(project)",
            commands: [
                TerminalCommand(
                    prompt: "dev@laptop:~/\(project)$", command: "npm install",
                    output: [
                        "",
                        "added \(pkgCount) packages, and audited \(pkgCount + Int.random(in: 1...50)) packages in \(dur)",
                        "",
                        "\(Int.random(in: 100...350)) packages are looking for funding",
                        "  run `npm fund` for details",
                        "",
                        "found \(rand(["0 vulnerabilities", "1 moderate severity vulnerability", "2 low severity vulnerabilities"]))",
                    ]),
                TerminalCommand(
                    prompt: "dev@laptop:~/\(project)$", command: "npm run build",
                    output: [
                        "",
                        "> \(project)@\(version) build",
                        "> vite build",
                        "",
                        "vite v\(Int.random(in: 4...5)).\(Int.random(in: 0...3)).\(Int.random(in: 0...15)) building for production...",
                        "✓ \(Int.random(in: 50...500)) modules transformed.",
                        "dist/index.html                    \(Int.random(in: 1...5)).\(Int.random(in: 0...9)) kB",
                        "dist/assets/index-\(String(format: "%08x", Int.random(in: 0...0xFFFF_FFFF))).css   \(Int.random(in: 20...150)).\(Int.random(in: 0...9)) kB │ gzip: \(Int.random(in: 5...40)).\(Int.random(in: 0...9)) kB",
                        "dist/assets/index-\(String(format: "%08x", Int.random(in: 0...0xFFFF_FFFF))).js    \(Int.random(in: 100...800)).\(Int.random(in: 0...9)) kB │ gzip: \(Int.random(in: 50...200)).\(Int.random(in: 0...9)) kB",
                        "✓ built in \(dur)",
                    ]),
                TerminalCommand(
                    prompt: "dev@laptop:~/\(project)$", command: "npm run test -- --coverage",
                    output: [
                        "",
                        "> \(project)@\(version) test",
                        "> jest --coverage",
                        "",
                        " PASS  src/__tests__/auth.test.ts (\(Int.random(in: 1...5)).\(Int.random(in: 0...9))s)",
                        " PASS  src/__tests__/api.test.ts (\(Int.random(in: 1...3)).\(Int.random(in: 0...9))s)",
                        " PASS  src/__tests__/utils.test.ts",
                        "",
                        "Test Suites: \(Int.random(in: 5...20)) passed, \(Int.random(in: 5...20)) total",
                        "Tests:       \(Int.random(in: 40...200)) passed, \(Int.random(in: 40...200)) total",
                        "Snapshots:   \(Int.random(in: 5...30)) passed, \(Int.random(in: 5...30)) total",
                        "Time:        \(dur)",
                    ]),
            ])
    }

    // MARK: - Python Session
    static func pythonSession() -> TerminalSession {
        let script = rand(["train.py", "preprocess.py", "evaluate.py", "server.py", "migrate.py"])
        let pyVer = rand(["3.11.4", "3.12.1", "3.10.12", "3.9.18"])
        let epoch = Int.random(in: 1...50)
        let totalEpochs = Int.random(in: epoch...100)
        let loss = Double.random(in: 0.01...2.5)
        let acc = Double.random(in: 0.6...0.99)

        return TerminalSession(
            title: "python — \(script)",
            commands: [
                TerminalCommand(
                    prompt: "(venv) dev@ml-box:~/ml$", command: "python --version",
                    output: ["Python \(pyVer)"]),
                TerminalCommand(
                    prompt: "(venv) dev@ml-box:~/ml$", command: "pip install -r requirements.txt",
                    output: [
                        "Collecting torch==2.1.0",
                        "Collecting numpy>=1.24.0",
                        "Collecting pandas>=2.0.0",
                        "Collecting scikit-learn>=1.3.0",
                        "Collecting transformers>=4.35.0",
                        "Installing collected packages: torch, numpy, pandas, scikit-learn, transformers",
                        "Successfully installed torch-2.1.0 numpy-1.26.0 pandas-2.1.2 scikit-learn-1.3.2 transformers-4.35.2",
                    ]),
                TerminalCommand(
                    prompt: "(venv) dev@ml-box:~/ml$", command: "python \(script)",
                    output: [
                        "[INFO] Loading dataset...",
                        "[INFO] Dataset: \(Int.random(in: 10000...500000)) samples (\(Int.random(in: 70...85))% train, \(Int.random(in: 10...20))% val)",
                        "[INFO] Initializing model: \(rand(["ResNet50", "BERT-base", "GPT-2-small", "VGG16", "EfficientNet"]))",
                        "[INFO] Parameters: \(Int.random(in: 1...500))M trainable",
                        "",
                        "Epoch [\(epoch)/\(totalEpochs)]",
                        String(format: "  Train Loss: %.4f | Train Acc: %.4f", loss, acc),
                        String(
                            format: "  Val Loss:   %.4f | Val Acc:   %.4f",
                            loss * Double.random(in: 0.9...1.2), acc * Double.random(in: 0.95...1.0)
                        ),
                        "[INFO] Checkpoint saved to models/checkpoint_epoch_\(epoch).pt",
                    ]),
            ])
    }

    // MARK: - System Session
    static func systemSession() -> TerminalSession {
        let cpuPercent = Int.random(in: 5...85)
        let memUsed = Int.random(in: 2...14)
        let memTotal = rand(["16", "32", "64"])
        let user = rand(usernames)
        let host = rand(hostnames)

        return TerminalSession(
            title: "system — \(host)",
            commands: [
                TerminalCommand(
                    prompt: "\(user)@\(host):~$", command: "htop --sort-key=PERCENT_CPU",
                    output: [
                        "  CPU[\(String(repeating: "|", count: cpuPercent/5))\(String(repeating: " ", count: 20 - cpuPercent/5))\(cpuPercent)%]   Tasks: \(Int.random(in: 80...400)), \(Int.random(in: 1...8)) running",
                        "  Mem[\(String(repeating: "|", count: memUsed * 2))\(String(repeating: " ", count: 28 - memUsed * 2))\(memUsed).0G/\(memTotal).0G]   Load average: \(Double.random(in: 0.1...4.0).rounded(toPlaces: 2)) \(Double.random(in: 0.1...3.0).rounded(toPlaces: 2)) \(Double.random(in: 0.1...2.5).rounded(toPlaces: 2))",
                        "",
                        "  PID  USER      PRI  NI  CPU%  MEM%  COMMAND",
                        " \(Int.random(in: 1000...9999)) \(user)            20   0  \(Int.random(in: 10...60))%   \(Int.random(in: 1...8))%  node server.js",
                        " \(Int.random(in: 1000...9999)) \(user)            20   0  \(Int.random(in: 1...20))%   \(Int.random(in: 1...5))%  python worker.py",
                        " \(Int.random(in: 1000...9999)) postgres          20   0   \(Int.random(in: 1...10))%   \(Int.random(in: 2...6))%  postgres: autovacuum",
                        " \(Int.random(in: 1000...9999)) redis             20   0   \(Int.random(in: 0...3))%   \(Int.random(in: 0...2))%  redis-server",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@\(host):~$", command: "df -h",
                    output: [
                        "Filesystem      Size  Used Avail Use% Mounted on",
                        "/dev/sda1        \(rand(["100G", "250G", "500G", "1T"]))   \(Int.random(in: 20...80))G   \(Int.random(in: 20...200))G  \(Int.random(in: 15...75))% /",
                        "tmpfs           \(Int.random(in: 1...8))G  \(Int.random(in: 100...900))M     \(Int.random(in: 1...7))G   \(Int.random(in: 1...20))% /dev/shm",
                        "/dev/sdb1       \(rand(["1T", "2T", "4T"]))   \(Int.random(in: 100...800))G   \(Int.random(in: 100...900))G  \(Int.random(in: 10...70))% /data",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@\(host):~$", command: "uptime",
                    output: [
                        " \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))):\(String(format: "%02d", Int.random(in: 0...59)))  up \(Int.random(in: 1...120)) days, \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))),  \(Int.random(in: 1...5)) users,  load average: \(Double.random(in: 0.1...2.0).rounded(toPlaces: 2)), \(Double.random(in: 0.1...1.5).rounded(toPlaces: 2)), \(Double.random(in: 0.1...1.2).rounded(toPlaces: 2))"
                    ]),
            ])
    }

    // MARK: - Kubernetes Session
    static func kubernetesSession() -> TerminalSession {
        let ns = rand(["default", "production", "staging", "monitoring", "kube-system"])
        let app = rand(["api-server", "frontend", "worker", "scheduler", "gateway"])
        let replicas = Int.random(in: 1...10)
        let age = rand(["2d", "5h", "12m", "30d", "1h"])

        return TerminalSession(
            title: "kubectl — \(ns)",
            commands: [
                TerminalCommand(
                    prompt: "dev@workstation:~$", command: "kubectl get pods -n \(ns)",
                    output: [
                        "NAME                                    READY   STATUS    RESTARTS   AGE",
                        "\(app)-\(String(format: "%032x", Int.random(in: 0...0xFFFF_FFFF)).prefix(10))-\(String(format: "%05x", Int.random(in: 0...0xFFFFF)).prefix(5))   1/1     Running   0          \(age)",
                        "\(app)-\(String(format: "%032x", Int.random(in: 0...0xFFFF_FFFF)).prefix(10))-\(String(format: "%05x", Int.random(in: 0...0xFFFFF)).prefix(5))   1/1     Running   \(Int.random(in: 0...3))          \(rand(["3d", "2h", "45m", "7d"]))",
                        "postgres-0                              1/1     Running   0          \(rand(["10d", "30d", "5d"]))",
                        "redis-master-0                          1/1     Running   0          \(rand(["10d", "25d", "8d"]))",
                    ]),
                TerminalCommand(
                    prompt: "dev@workstation:~$", command: "kubectl get deployments -n \(ns)",
                    output: [
                        "NAME          READY   UP-TO-DATE   AVAILABLE   AGE",
                        "\(app)         \(replicas)/\(replicas)     \(replicas)            \(replicas)           \(rand(["15d", "3d", "2d"]))",
                        "frontend      \(Int.random(in: 2...5))/\(replicas)     \(replicas)            \(replicas)           \(rand(["30d", "10d", "5d"]))",
                    ]),
                TerminalCommand(
                    prompt: "dev@workstation:~$",
                    command: "kubectl rollout status deployment/\(app) -n \(ns)",
                    output: [
                        "Waiting for deployment \"\(app)\" rollout to finish: \(Int.random(in: 0...replicas)) out of \(replicas) new replicas have been updated...",
                        "Waiting for deployment \"\(app)\" rollout to finish: \(replicas - 1) old replicas are pending termination...",
                        "deployment \"\(app)\" successfully rolled out",
                    ]),
            ])
    }

    // MARK: - SSH Session
    static func sshSession() -> TerminalSession {
        let server = rand([
            "prod-01.example.com", "api.internal", "db-replica.internal", "192.168.1.50",
            "10.0.0.24",
        ])
        let user = rand(["ubuntu", "ec2-user", "deploy", "admin"])
        let port = rand(["22", "2222", "2200"])

        return TerminalSession(
            title: "ssh — \(server)",
            commands: [
                TerminalCommand(
                    prompt: "local@macbook:~$", command: "ssh -p \(port) \(user)@\(server)",
                    output: [
                        "The authenticity of host '\(server) (\(server))' can't be established.",
                        "ED25519 key fingerprint is SHA256:\(String(format: "%40x", Int.random(in: 0...Int.max)).prefix(40)).",
                        "Are you sure you want to continue connecting (yes/no/[fingerprint])? yes",
                        "Warning: Permanently added '\(server)' (ED25519) to the list of known hosts.",
                        "",
                        "Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-89-generic x86_64)",
                        "",
                        " * Documentation:  https://help.ubuntu.com",
                        " * Management:     https://landscape.canonical.com",
                        "",
                        "Last login: \(rand(["Mon", "Tue", "Wed", "Thu", "Fri"])) Nov \(Int.random(in: 1...30)) \(Int.random(in: 8...22)):\(String(format: "%02d", Int.random(in: 0...59))):\(String(format: "%02d", Int.random(in: 0...59))) 2025 from \(rand(["10.0.0.1", "192.168.0.1", "172.16.0.5"]))",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@\(server):~$", command: "systemctl status nginx",
                    output: [
                        "● nginx.service - A high performance web server",
                        "     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)",
                        "     Active: \u{1B}[32mactive (running)\u{1B}[0m since Mon 2025-11-11 08:00:00 UTC; \(rand(["5 days", "2 hours", "3 weeks"])) ago",
                        "    Process: \(Int.random(in: 1000...9999)) ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)",
                        "   Main PID: \(Int.random(in: 1000...9999)) (nginx)",
                        "      Tasks: \(Int.random(in: 2...8)) (limit: 4696)",
                        "     Memory: \(Int.random(in: 5...50)).\(Int.random(in: 0...9))M",
                        "        CPU: \(Int.random(in: 1...10)).\(Int.random(in: 0...9))s",
                    ]),
            ])
    }

    // MARK: - Build / CI Session
    static func buildSession() -> TerminalSession {
        let project = rand(["core-api", "data-service", "auth-module", "payment-gateway"])
        let tool = rand(["make", "gradle", "cmake", "bazel"])
        let target = rand(["build", "test", "release", "package", "install"])
        let duration = "\(Int.random(in: 5...120)).\(Int.random(in: 0...9))"
        let warnings = Int.random(in: 0...15)
        let tests = Int.random(in: 50...500)

        return TerminalSession(
            title: "\(tool) — \(project)",
            commands: [
                TerminalCommand(
                    prompt: "ci@build-node:~/\(project)$", command: "\(tool) \(target)",
                    output: [
                        "Starting build for \(project)...",
                        "[1/\(Int.random(in: 5...20))] Checking dependencies",
                        "[2/\(Int.random(in: 5...20))] Compiling source files",
                        "  src/main.cpp:  compiled successfully",
                        "  src/utils.cpp: compiled successfully",
                        "  src/server.cpp: compiled successfully",
                        warnings > 0
                            ? "  \u{1B}[33m\(warnings) warning(s) generated\u{1B}[0m"
                            : "  No warnings",
                        "[3/\(Int.random(in: 5...20))] Linking binaries",
                        "[4/\(Int.random(in: 5...20))] Running tests (\(tests) total)",
                        "  \u{1B}[32m✓\u{1B}[0m \(tests) tests passed",
                        "",
                        "\u{1B}[32mBuild successful\u{1B}[0m [\(duration)s]",
                    ])
            ])
    }

    // MARK: - Database Session
    static func databaseSession() -> TerminalSession {
        let db = rand(["production_db", "analytics", "users_db", "orders", "metrics"])
        let rows = Int.random(in: 100...9_999_999)
        let ms = Int.random(in: 1...500)

        return TerminalSession(
            title: "psql — \(db)",
            commands: [
                TerminalCommand(
                    prompt: "psql -U admin -d \(db)", command: "\\l",
                    output: [
                        "                               List of databases",
                        "      Name      |  Owner  | Encoding |  Collate   |   Ctype",
                        "----------------+---------+----------+------------+------------",
                        " \(db)          | admin   | UTF8     | en_US.UTF8 | en_US.UTF8",
                        " analytics      | admin   | UTF8     | en_US.UTF8 | en_US.UTF8",
                        " template0      | admin   | UTF8     | en_US.UTF8 | en_US.UTF8",
                        " template1      | admin   | UTF8     | en_US.UTF8 | en_US.UTF8",
                    ]),
                TerminalCommand(
                    prompt: "\(db)=#",
                    command: "SELECT COUNT(*), MAX(created_at) FROM users WHERE active = true;",
                    output: [
                        "  count  |          max",
                        "---------+----------------------------",
                        " \(rows) | 2025-11-\(Int.random(in: 1...28)) \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))):\(String(format: "%02d", Int.random(in: 0...59)))+00",
                        "(1 row)",
                        "",
                        "Time: \(ms).\(Int.random(in: 0...9)) ms",
                    ]),
                TerminalCommand(
                    prompt: "\(db)=#",
                    command:
                        "EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'pending' LIMIT 100;",
                    output: [
                        "                                QUERY PLAN",
                        "---------------------------------------------------------------------------",
                        " Limit  (cost=0.00..\(Double.random(in: 10...500).rounded(toPlaces: 2)) rows=100 width=\(Int.random(in: 50...200)))",
                        "   ->  Seq Scan on orders  (cost=0.00..\(Double.random(in: 100...10000).rounded(toPlaces: 2)) rows=\(Int.random(in: 1000...100000)) width=\(Int.random(in: 50...200)))",
                        "         Filter: ((status)::text = 'pending')",
                        " Planning Time: \(Double.random(in: 0.1...5.0).rounded(toPlaces: 3)) ms",
                        " Execution Time: \(Double.random(in: 1.0...50.0).rounded(toPlaces: 3)) ms",
                        "(6 rows)",
                    ]),
            ])
    }

    // MARK: - Network Session
    static func networkSession() -> TerminalSession {
        let host = rand(["api.example.com", "8.8.8.8", "github.com", "cloudflare.com", "10.0.0.1"])
        let user = rand(usernames)

        return TerminalSession(
            title: "network — diagnostics",
            commands: [
                TerminalCommand(
                    prompt: "\(user)@server:~$", command: "ping -c 5 \(host)",
                    output: (0..<5).map { i in
                        "64 bytes from \(host): icmp_seq=\(i) ttl=\(Int.random(in: 50...128)) time=\(Double.random(in: 0.5...50.0).rounded(toPlaces: 3)) ms"
                    } + [
                        "",
                        "--- \(host) ping statistics ---",
                        "5 packets transmitted, 5 received, 0% packet loss, time \(Int.random(in: 4000...4999))ms",
                        "rtt min/avg/max/mdev = \(Double.random(in: 0.5...5.0).rounded(toPlaces: 3))/\(Double.random(in: 5.0...20.0).rounded(toPlaces: 3))/\(Double.random(in: 20.0...50.0).rounded(toPlaces: 3))/\(Double.random(in: 0.1...2.0).rounded(toPlaces: 3)) ms",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@server:~$", command: "curl -I https://\(host)",
                    output: [
                        "HTTP/2 200",
                        "date: \(rand(["Mon", "Tue", "Wed", "Thu", "Fri"])), \(Int.random(in: 1...28)) Nov 2025 \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))):\(String(format: "%02d", Int.random(in: 0...59))) GMT",
                        "content-type: application/json; charset=utf-8",
                        "content-length: \(Int.random(in: 100...50000))",
                        "cache-control: max-age=\(Int.random(in: 0...3600))",
                        "x-request-id: \(UUID().uuidString.lowercased())",
                        "cf-ray: \(String(format: "%016x", Int.random(in: 0...Int.max)).prefix(16))",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@server:~$", command: "netstat -tuln | head -15",
                    output: [
                        "Active Internet connections (only servers)",
                        "Proto Recv-Q Send-Q Local Address     Foreign Address   State",
                        "tcp        0      0 0.0.0.0:22        0.0.0.0:*         LISTEN",
                        "tcp        0      0 0.0.0.0:80        0.0.0.0:*         LISTEN",
                        "tcp        0      0 0.0.0.0:443       0.0.0.0:*         LISTEN",
                        "tcp        0      0 127.0.0.1:5432    0.0.0.0:*         LISTEN",
                        "tcp        0      0 127.0.0.1:6379    0.0.0.0:*         LISTEN",
                        "tcp        0      0 0.0.0.0:\(rand(["3000", "8080", "8000"]))       0.0.0.0:*         LISTEN",
                    ]),
            ])
    }

    // MARK: - File Operations Session
    static func fileSession() -> TerminalSession {
        let dir = rand(["logs", "backups", "data", "uploads", "cache"])
        let user = rand(usernames)
        let host = rand(hostnames)

        return TerminalSession(
            title: "bash — files",
            commands: [
                TerminalCommand(
                    prompt: "\(user)@\(host):~$", command: "ls -lah /var/\(dir)/",
                    output: [
                        "total \(Int.random(in: 100...9000))M",
                        "drwxr-xr-x  \(Int.random(in: 2...20)) root root  \(Int.random(in: 1...10))K Nov \(Int.random(in: 1...28)) \(Int.random(in: 8...23)):\(String(format: "%02d", Int.random(in: 0...59))) .",
                        "drwxr-xr-x  \(Int.random(in: 5...30)) root root  \(Int.random(in: 1...5))K Nov \(Int.random(in: 1...28)) 12:00 ..",
                        "-rw-r--r--  1 root root \(Int.random(in: 1...500))M Nov \(Int.random(in: 1...28)) 00:00 app-\(rand(["debug", "error", "access"]))-2025-11-\(Int.random(in: 1...28)).log",
                        "-rw-r--r--  1 root root \(Int.random(in: 1...200))M Nov \(Int.random(in: 1...28)) 00:00 app-\(rand(["debug", "error", "access"]))-2025-11-\(Int.random(in: 1...28)).log",
                        "-rw-r--r--  1 root root \(Int.random(in: 1...100))M Nov \(Int.random(in: 1...25)) 00:00 app-\(rand(["debug", "error", "access"]))-2025-11-\(Int.random(in: 1...25)).log",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@\(host):~$",
                    command: "find /var/\(dir) -name '*.log' -mtime +7 | wc -l",
                    output: ["\(Int.random(in: 5...200))"]),
                TerminalCommand(
                    prompt: "\(user)@\(host):~$",
                    command: "tar -czf backup-$(date +%Y%m%d).tar.gz /var/\(dir)/",
                    output: [
                        "tar: Removing leading '/' from member names",
                        "/var/\(dir)/",
                        "/var/\(dir)/data.db",
                        "Compressed: \(Int.random(in: 100...5000))M -> \(Int.random(in: 50...1000))M (\(Int.random(in: 20...80))% reduction)",
                    ]),
            ])
    }

    // MARK: - Process Management Session
    static func processSession() -> TerminalSession {
        let user = rand(usernames)
        let host = rand(hostnames)
        let pid = Int.random(in: 1000...9999)

        return TerminalSession(
            title: "ps — processes",
            commands: [
                TerminalCommand(
                    prompt: "\(user)@\(host):~$", command: "ps aux --sort=-%cpu | head -12",
                    output: [
                        "USER       PID %CPU %MEM    VSZ   RSS TTY  STAT START   TIME COMMAND",
                        "\(user)    \(pid)  \(Int.random(in: 10...90)).\(Int.random(in: 0...9))  \(Int.random(in: 1...20)).\(Int.random(in: 0...9)) \(Int.random(in: 100000...999999)) \(Int.random(in: 10000...500000)) ?  Ssl  Nov\(Int.random(in: 1...30))  \(Int.random(in: 10...999)):\(String(format: "%02d", Int.random(in: 0...59))) node /app/server.js",
                        "\(user)    \(pid+1) \(Int.random(in: 5...40)).\(Int.random(in: 0...9))  \(Int.random(in: 1...10)).\(Int.random(in: 0...9)) \(Int.random(in: 50000...500000)) \(Int.random(in: 5000...200000)) ?  S    \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59)))  \(Int.random(in: 0...100)):\(String(format: "%02d", Int.random(in: 0...59))) python worker.py",
                        "postgres  \(pid+2) \(Int.random(in: 1...15)).\(Int.random(in: 0...9))   \(Int.random(in: 1...5)).\(Int.random(in: 0...9)) \(Int.random(in: 50000...300000)) \(Int.random(in: 5000...100000)) ?  Ss   Nov\(Int.random(in: 1...15))  \(Int.random(in: 1...200)):\(String(format: "%02d", Int.random(in: 0...59))) postgres: main process",
                        "redis     \(pid+3) \(Int.random(in: 0...5)).\(Int.random(in: 0...9))   \(Int.random(in: 0...3)).\(Int.random(in: 0...9)) \(Int.random(in: 10000...100000))  \(Int.random(in: 1000...50000)) ?  Ssl  Nov\(Int.random(in: 1...15))   \(Int.random(in: 1...50)):\(String(format: "%02d", Int.random(in: 0...59))) redis-server 127.0.0.1:6379",
                    ]),
                TerminalCommand(
                    prompt: "\(user)@\(host):~$",
                    command: "lsof -i TCP:\(rand(["3000", "8080", "5432", "6379"]))",
                    output: [
                        "COMMAND   PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME",
                        "node    \(pid)  \(user)   22u  IPv4  \(Int.random(in: 10000...99999))      0t0  TCP *:\(rand(["3000", "8080"])) (LISTEN)",
                        "node    \(pid)  \(user)   23u  IPv4  \(Int.random(in: 10000...99999))      0t0  TCP localhost:\(rand(["3000", "8080"]))->localhost:\(Int.random(in: 40000...60000)) (ESTABLISHED)",
                    ]),
            ])
    }

    // MARK: - Rust / Cargo Session
    static func rustSession() -> TerminalSession {
        let project = rand(["cli-tool", "web-server", "parser", "compiler", "runtime"])
        let version = "\(Int.random(in: 0...1)).\(Int.random(in: 50...80)).\(Int.random(in: 0...5))"

        return TerminalSession(
            title: "cargo — \(project)",
            commands: [
                TerminalCommand(
                    prompt: "dev@machine:~/\(project)$", command: "cargo build --release",
                    output: [
                        "   Compiling proc-macro2 v1.0.70",
                        "   Compiling quote v1.0.33",
                        "   Compiling syn v2.0.39",
                        "   Compiling serde v1.0.193",
                        "   Compiling tokio v1.35.0",
                        "   Compiling hyper v1.0.1",
                        "   Compiling \(project) v\(version) (/home/dev/\(project))",
                        "    Finished `release` profile [optimized] target(s) in \(Int.random(in: 10...120)).\(Int.random(in: 0...9))s",
                    ]),
                TerminalCommand(
                    prompt: "dev@machine:~/\(project)$", command: "cargo test",
                    output: [
                        "   Compiling \(project) v\(version) (/home/dev/\(project))",
                        "    Finished test [unoptimized + debuginfo] target(s) in \(Int.random(in: 2...30)).\(Int.random(in: 0...9))s",
                        "     Running unittests src/main.rs (target/debug/deps/\(project)-\(String(format: "%016x", Int.random(in: 0...Int.max)).prefix(16)))",
                        "",
                        "running \(Int.random(in: 10...80)) tests",
                        "test tests::parse_valid_input ... ok",
                        "test tests::handle_error_case ... ok",
                        "test tests::concurrent_access ... ok",
                        "test tests::performance_benchmark ... ok",
                        "",
                        "test result: \u{1B}[32mok\u{1B}[0m. \(Int.random(in: 10...80)) passed; 0 failed; 0 ignored; 0 measured",
                    ]),
            ])
    }

    // MARK: - AWS CLI Session
    static func awsSession() -> TerminalSession {
        let region = rand(["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"])
        let bucket = rand(["my-app-assets", "prod-backups", "ml-datasets", "static-files"])
        let stack = rand(["production-api", "staging-infra", "data-pipeline", "ml-training"])

        return TerminalSession(
            title: "aws — \(region)",
            commands: [
                TerminalCommand(
                    prompt: "dev@laptop:~$", command: "aws s3 ls s3://\(bucket)/ --human-readable",
                    output: [
                        "                           PRE assets/",
                        "                           PRE uploads/",
                        "2025-11-\(Int.random(in: 1...28)) \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))):\(String(format: "%02d", Int.random(in: 0...59)))   \(Int.random(in: 1...500)).\(Int.random(in: 0...9)) MB data.json",
                        "2025-11-\(Int.random(in: 1...28)) \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))):\(String(format: "%02d", Int.random(in: 0...59)))   \(Int.random(in: 1...200)).\(Int.random(in: 0...9)) MB backup.tar.gz",
                        "2025-11-\(Int.random(in: 1...28)) \(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))):\(String(format: "%02d", Int.random(in: 0...59)))   \(Int.random(in: 1...50)).\(Int.random(in: 0...9)) MB config.yml",
                    ]),
                TerminalCommand(
                    prompt: "dev@laptop:~$",
                    command: "aws cloudformation describe-stacks --stack-name \(stack)",
                    output: [
                        "{",
                        "    \"Stacks\": [",
                        "        {",
                        "            \"StackId\": \"arn:aws:cloudformation:\(region):\(Int.random(in: 100_000_000_000...999_999_999_999)):stack/\(stack)/\(UUID().uuidString.lowercased())\",",
                        "            \"StackName\": \"\(stack)\",",
                        "            \"StackStatus\": \"\(rand(["CREATE_COMPLETE", "UPDATE_COMPLETE", "UPDATE_IN_PROGRESS"]))\",",
                        "            \"CreationTime\": \"2025-\(String(format: "%02d", Int.random(in: 1...11)))-\(String(format: "%02d", Int.random(in: 1...28)))T\(Int.random(in: 0...23)):\(String(format: "%02d", Int.random(in: 0...59))):00Z\"",
                        "        }",
                        "    ]",
                        "}",
                    ]),
            ])
    }
}

// MARK: - Double extension

extension Double {
    fileprivate func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
