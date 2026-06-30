# Terminal Screen Saver

A macOS screen saver that fills your screen with animated terminal windows running realistic fake commands — git logs, docker builds, kubernetes rollouts, npm installs, SQL queries, Rust cargo, AWS CLI, and more.

🌐 **[Website & live demo →](https://yemzikk.github.io/mac-terminal-screen-saver/)** &middot; ☕ **[Buy me a coffee](https://buymeacoffee.com/yemzikk)**

## Features

- **Multiple terminal windows** — 1–8 windows, arranged in automatic grid layouts
- **Typewriter animation** — commands typed out character by character with natural timing variation
- **Scrolling output** — command results appear line by line, then the window scrolls and repeats
- **8 built-in themes** — Hack Green, Amber CRT, Classic White, Solarized Dark, Monokai, Dracula, Nord, Blue Pulse
- **Per-window random themes** — each terminal can use a different theme
- **Visual effects** — CRT scanlines, vignette glow, macOS-style traffic-light buttons, window shadows
- **Live settings panel** — change everything from System Settings without editing any files

## Command Categories

| Category | Commands |
|----------|----------|
| Git | status, log, diff, stash |
| Docker | ps, build, logs |
| npm/Node | install, build, test |
| Python/ML | pip install, training epochs |
| Kubernetes | get pods/deployments, rollout status |
| SSH | connect, systemctl status |
| Rust/Cargo | build --release, test |
| AWS CLI | s3 ls, cloudformation |
| PostgreSQL | queries, EXPLAIN ANALYZE |
| System | htop, df, uptime |
| Network | ping, curl, netstat |
| Files | ls, find, tar |
| Processes | ps aux, lsof |

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode Command Line Tools (`xcode-select --install`)

## Installation

### Recommended: Build from Source

Locally-built bundles aren't quarantined by Gatekeeper, so this is the smoothest install:

```bash
git clone https://github.com/yemzikk/mac-terminal-screen-saver.git
cd mac-terminal-screen-saver
make install
```

This compiles a universal (Apple Silicon + Intel) binary and copies `TerminalScreenSaver.saver`
to `~/Library/Screen Savers/`.

Other build targets:

```bash
make              # build .saver bundle only (no install)
make install      # build + install (current user)
make install-system   # build + install system-wide (sudo)
make clean        # remove build/ directory
make uninstall    # remove from ~/Library/Screen Savers
```

### Download a Pre-built Release

1. Go to [Releases](https://github.com/yemzikk/mac-terminal-screen-saver/releases)
2. Download either:
   - **TerminalScreenSaver.dmg** — macOS disk image
   - **TerminalScreenSaver.saver.zip** — compressed bundle
3. Unzip / open the DMG and double-click `TerminalScreenSaver.saver`, then click **Install**

The screensaver installs to `~/Library/Screen Savers/`.

> **Gatekeeper note:** Released bundles are **ad-hoc signed but not notarized** (no paid Apple
> Developer account). Because they're downloaded from the internet, macOS quarantines them and may
> refuse to load the saver or warn about an "unidentified developer." To clear the quarantine flag:
>
> ```bash
> xattr -dr com.apple.quarantine ~/Downloads/TerminalScreenSaver.saver
> ```
>
> (adjust the path to wherever the `.saver` ended up), then double-click it again.
> Building from source avoids this entirely.

### Homebrew (tap)

If a tap is published, you can install via:

```bash
brew tap yemzikk/tap
brew install --cask --no-quarantine terminal-screensaver
```

`--no-quarantine` is needed because the bundle is ad-hoc signed but not notarized.
Setup instructions for publishing the tap live in
[packaging/homebrew/README.md](packaging/homebrew/README.md).

> Not available in the main `homebrew/cask` repo, which requires notarized bundles.

## Activate

1. Open **System Settings → Screen Saver**
2. Scroll down and select **Terminal Screen Saver**
3. Click **Options…** or the gear icon to open the settings panel

## Settings Panel

| Setting | Description |
|---------|-------------|
| **Terminals** | Number of terminal windows (1–8) |
| **Color Theme** | Choose from 8 built-in themes |
| **Random Theme Per Window** | Each terminal gets a different theme |
| **Font Size** | Terminal font size (8–18 pt) |
| **Typing Speed** | Characters per second (5–120) |
| **Corner Radius** | Window corner rounding |
| **Terminal Opacity** | Window background transparency |
| **Show Title Bar** | macOS-style title bar with traffic lights |
| **Scanlines** | CRT scanline overlay |
| **Vignette Glow** | Radial dark vignette around edges |
| **Blinking Cursor** | Block cursor blinking |
| **Window Shadow** | Outer glow shadow |

## Project Structure

```
mac-terminal-screen-saver/
├── Sources/TerminalScreenSaver/
│   ├── Settings.swift              # Settings model + 8 built-in themes
│   ├── CommandDatabase.swift       # 14 command categories with realistic output
│   ├── TerminalWindowView.swift    # Terminal window rendering + typewriter animation
│   ├── TerminalScreenSaverView.swift  # Main ScreenSaverView, layout engine
│   └── ConfigSheetController.swift # Settings panel (fully programmatic NSPanel)
├── Resources/
│   └── Info.plist                  # Bundle metadata
├── Makefile                        # Build + install rules
└── README.md
```

## Themes Preview

| Theme | Background | Text |
|-------|-----------|------|
| Hack Green | Near-black | Bright green |
| Amber CRT | Dark amber | Warm amber/gold |
| Classic White | Dark navy | Light grey/white |
| Solarized Dark | Solarized base03 | Base0 |
| Monokai | #282828 | Off-white |
| Dracula | Purple-dark | Soft white |
| Nord | Arctic dark | Arctic light |
| Blue Pulse | Deep navy | Electric blue |

## License

MIT — do whatever you want with it.
