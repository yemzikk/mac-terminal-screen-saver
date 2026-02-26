import Foundation

// MARK: - EasterEggs
// Subtle ZikKit / yemzikk references hidden in realistic terminal sessions.
// Shown with low probability — easy to miss unless you're really watching.

class EasterEggs {

    // ~1-in-15 chance of picking an easter-egg session instead of a normal one
    static let selectionWeight = 15

    static func randomEasterEggSession() -> TerminalSession? {
        guard Int.random(in: 0..<selectionWeight) == 0 else { return nil }
        let pool: [() -> TerminalSession] = [
            zikkitCurlSession,
            zikkitGitSession,
            firedashDevSession,
            keralaDashSession,
            fireflyEmailSession,
        ]
        return pool.randomElement()!()
    }

    // MARK: - curl / API session
    // Shows a curl hitting the ZikKit tools API or the azan API
    private static func zikkitCurlSession() -> TerminalSession {
        let ep = [
            (
                "GET",
                "https://yemzikk.in/tools/api/gst?amount=\(Int.random(in: 5000...100000))&rate=18",
                """
                {
                  "original_amount": \(Int.random(in: 5000...100000)),
                  "gst_rate": 18,
                  "gst_amount": \(Int.random(in: 900...18000)),
                  "total": \(Int.random(in: 5900...118000)),
                  "cgst": \(Int.random(in: 450...9000)),
                  "sgst": \(Int.random(in: 450...9000))
                }
                """
            ),
            (
                "GET",
                "https://yemzikk.in/tools/api/ksrtc-refund?pnr=KL\(Int.random(in: 10_000_000...99_999_999))&hours_before=\(Int.random(in: 1...48))",
                """
                {
                  "pnr": "KL\(Int.random(in: 10_000_000...99_999_999))",
                  "refund_percent": \(Int.random(in: 25...90)),
                  "refund_amount": \(Int.random(in: 100...2000)).00,
                  "status": "eligible"
                }
                """
            ),
        ].randomElement()!

        let outputLines: [String] =
            [
                "  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current",
                "                                 Dload  Upload   Total   Spent    Left  Speed",
                "100   \(Int.random(in: 80...300))  100   \(Int.random(in: 80...300))    0     0   \(Int.random(in: 200...9000))      0 --:--:-- --:--:-- --:--:--  \(Int.random(in: 1000...9000))",
            ] + ep.2.components(separatedBy: "\n").map { $0.isEmpty ? "" : $0 }

        return TerminalSession(
            title: "curl — yemzikk.in/tools",
            commands: [
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/tools$",
                    command: "curl -sL \"\(ep.1)\" | python3 -m json.tool",
                    output: outputLines
                ),
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/tools$",
                    command: "echo $?",
                    output: ["0"]
                ),
            ])
    }

    // MARK: - git session referencing real ZikKit repos
    private static func zikkitGitSession() -> TerminalSession {
        typealias RepoInfo = (name: String, commits: [String])
        let repos: [RepoInfo] = [
            (
                "FireDash",
                [
                    "Update keyboard shortcuts and enhance sidebar navigation with new tools",
                    "added proxy routing",
                    "fix: correct HTTPS enforcement in proxy function",
                    "feat: add spending trends chart with 6/12 month view",
                    "feat: add savings goals tracker",
                    "first commit",
                ]
            ),
            (
                "time-format-converter",
                [
                    "Refactor site management logic to implement whitelist and blacklist",
                    "Add global enable/disable toggle and per-site control for time format",
                    "Enhance time format conversion features with improved state management",
                    "Add new icon images for application",
                    "first commit",
                ]
            ),
            (
                "azan-api",
                [
                    "Sync public and v1/timesheets from azan (\(String(format: "%02d", Int.random(in: 1...28)))-\(String(format: "%02d", Int.random(in: 1...12)))-2026)",
                    "Sync public and v1/timesheets from azan",
                    "add sitemap and robots.txt",
                    "update dashboard styles",
                    "first commit",
                ]
            ),
            (
                "firefly-iii-email-summary",
                [
                    "fix: handle missing category gracefully",
                    "feat: add net worth delta to monthly summary",
                    "chore: update README with setup instructions",
                    "refactor: extract template rendering to helper",
                    "initial commit",
                ]
            ),
            (
                "Useful-Scripts",
                [
                    "add: script to bulk-rename files by date",
                    "add: git-cleanup script for merged branches",
                    "fix: path handling on macOS for backup script",
                    "chore: reorganise into subdirectories",
                    "initial commit",
                ]
            ),
        ]
        let repo = repos.randomElement()!
        let shuffledCommits = repo.commits.shuffled()
        let hash1 = String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))
        let hash2 = String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF))

        return TerminalSession(
            title: "git — yemzikk/\(repo.name)",
            commands: [
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/\(repo.name)$",
                    command: "git log --oneline -5",
                    output: ([hash1 + " (HEAD -> main, origin/main) " + shuffledCommits[0]]
                        + shuffledCommits.dropFirst().prefix(4).map {
                            String(format: "%07x", Int.random(in: 0x1000000...0xFFFFFFF)) + " " + $0
                        })
                ),
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/\(repo.name)$",
                    command: "git remote -v",
                    output: [
                        "origin\thttps://github.com/yemzikk/\(repo.name).git (fetch)",
                        "origin\thttps://github.com/yemzikk/\(repo.name).git (push)",
                    ]
                ),
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/\(repo.name)$",
                    command: "git push origin main",
                    output: [
                        "Enumerating objects: \(Int.random(in: 3...12)), done.",
                        "Counting objects: 100% (\(Int.random(in: 3...12))/\(Int.random(in: 3...12))), done.",
                        "Delta compression using up to 8 threads",
                        "Compressing objects: 100% (\(Int.random(in: 2...8))/\(Int.random(in: 2...8))), done.",
                        "Writing objects: 100% (\(Int.random(in: 2...6))/\(Int.random(in: 2...6))), \(Int.random(in: 1...20)).\(Int.random(in: 0...9)) KiB | \(Int.random(in: 500...9000)) KiB/s, done.",
                        "To https://github.com/yemzikk/\(repo.name).git",
                        "   \(hash2)..\(hash1)  main -> main",
                    ]
                ),
            ])
    }

    // MARK: - FireDash local dev session (Cloudflare Wrangler)
    private static func firedashDevSession() -> TerminalSession {
        let port = 8788
        return TerminalSession(
            title: "wrangler — FireDash",
            commands: [
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/FireDash$",
                    command: "git pull",
                    output: [
                        "remote: Enumerating objects: 5, done.",
                        "remote: Counting objects: 100% (5/5), done.",
                        "remote: Compressing objects: 100% (3/3), done.",
                        "Updating c3fbc11..d1a\(String(format: "%04x", Int.random(in: 0x1000...0xFFFF)))",
                        "Fast-forward",
                        " index.html | \(Int.random(in: 4...30)) \(String(repeating: "+", count: Int.random(in: 2...12)))\(String(repeating: "-", count: Int.random(in: 0...4)))",
                        " \(Int.random(in: 1...3)) file(s) changed, \(Int.random(in: 4...30)) insertion(s)(+), \(Int.random(in: 0...8)) deletion(s)(-)",
                    ]
                ),
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/FireDash$",
                    command: "npx wrangler pages dev .",
                    output: [
                        " ⛅️ wrangler 3.\(Int.random(in: 50...80)).\(Int.random(in: 0...9))",
                        "-------------------",
                        "✨ Compiled Worker successfully",
                        "b  [b] open a browser, [d] open Devtools, [l] turn off local mode, [c] clear console, [x] to exit",
                        "[mf:inf] Ready on http://localhost:\(port)",
                        "[mf:inf] - http://127.0.0.1:\(port)",
                        "GET / 200 OK (\(Int.random(in: 2...18))ms)",
                        "GET /api/v1/about 200 OK (\(Int.random(in: 15...120))ms)",
                    ]
                ),
            ])
    }

    // MARK: - Kerala Azan API session (api.azantimes.in)
    private static func keralaDashSession() -> TerminalSession {
        let district = [
            "Kozhikode", "Thrissur", "Ernakulam", "Thiruvananthapuram",
            "Malappuram", "Kannur", "Kollam",
        ].randomElement()!
        let fajr = "\(Int.random(in: 5...6)):\(String(format: "%02d", Int.random(in: 0...59))) AM"
        let dhuhr = "12:\(String(format: "%02d", Int.random(in: 20...45))) PM"
        let asr = "\(Int.random(in: 3...4)):\(String(format: "%02d", Int.random(in: 0...59))) PM"
        let maghrib =
            "\(Int.random(in: 6...7)):\(String(format: "%02d", Int.random(in: 0...45))) PM"
        let isha = "\(Int.random(in: 7...8)):\(String(format: "%02d", Int.random(in: 15...59))) PM"

        return TerminalSession(
            title: "curl — api.azantimes.in",
            commands: [
                TerminalCommand(
                    prompt: "yemzikk@macbook:~$",
                    command:
                        "curl -sL \"https://api.azantimes.in/v1/today?district=\(district.lowercased())\" | jq .",
                    output: [
                        "{",
                        "  \"district\": \"\(district)\",",
                        "  \"date\": \"2026-\(String(format: "%02d", Int.random(in: 1...12)))-\(String(format: "%02d", Int.random(in: 1...28)))\",",
                        "  \"fajr\": \"\(fajr)\",",
                        "  \"sunrise\": \"\(Int.random(in: 6...7)):\(String(format: "%02d", Int.random(in: 0...30))) AM\",",
                        "  \"dhuhr\": \"\(dhuhr)\",",
                        "  \"asr\": \"\(asr)\",",
                        "  \"maghrib\": \"\(maghrib)\",",
                        "  \"isha\": \"\(isha)\"",
                        "}",
                    ]
                ),
                TerminalCommand(
                    prompt: "yemzikk@macbook:~$",
                    command: "# dashboard → https://azantimes.in",
                    output: []
                ),
            ])
    }

    // MARK: - Firefly III email summary script (github.com/yemzikk/firefly-iii-email-summary)
    private static func fireflyEmailSession() -> TerminalSession {
        let month = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December",
        ].randomElement()!
        let income = Int.random(in: 30000...120000)
        let expense = Int.random(in: 15000...income)
        let balance = income - expense

        return TerminalSession(
            title: "python — firefly-iii-email-summary",
            commands: [
                TerminalCommand(
                    prompt: "yemzikk@macbook:~/firefly-iii-email-summary$",
                    command: "python3 send_report.py --month \(month) --to yemzikk@gmail.com",
                    output: [
                        "[INFO] Connecting to Firefly III at http://localhost:8080...",
                        "[INFO] Fetching transactions for \(month)...",
                        "[INFO] Income:   ₹\(income)",
                        "[INFO] Expenses: ₹\(expense)",
                        "[INFO] Balance:  ₹\(balance)",
                        "[INFO] Rendering HTML email template...",
                        "[INFO] Sending via SMTP...",
                        "[INFO] Report sent successfully. ✓",
                        "[INFO] Dashboard → https://firedash.yemzikk.in",
                    ]
                )
            ])
    }
}
