# Homebrew Tap Setup

This directory holds the Homebrew Cask for distributing the screen saver without a
paid Apple Developer ID. The bundle is ad-hoc signed but **not notarized**, so it
can't go in the main `homebrew/cask` repo — it must live in your own tap.

## One-time: create the tap repo

Homebrew taps must be named `homebrew-<name>`. Create a repo called `homebrew-tap`
under your GitHub account, then:

```bash
git clone https://github.com/yemzikk/homebrew-tap.git
cd homebrew-tap
mkdir -p Casks
cp /path/to/mac-terminal-screen-saver/packaging/homebrew/terminal-screensaver.rb Casks/
git add Casks/terminal-screensaver.rb
git commit -m "Add terminal-screensaver cask"
git push
```

## Each release: update version + checksum

The cask points at a GitHub Release asset (`TerminalScreenSaver.saver.zip`).
After publishing a release:

```bash
# Download the released zip and compute its checksum:
curl -sL -o /tmp/tss.zip \
  https://github.com/yemzikk/mac-terminal-screen-saver/releases/download/v1.0/TerminalScreenSaver.saver.zip
shasum -a 256 /tmp/tss.zip
```

Edit `Casks/terminal-screensaver.rb`:
- set `version` to match the release tag (without the `v`)
- paste the checksum into `sha256`

Commit and push.

## How users install

```bash
brew tap yemzikk/tap
brew install --cask --no-quarantine terminal-screensaver
```

`--no-quarantine` is required because the bundle isn't notarized; without it macOS
may refuse to load the saver. (Building from source avoids this entirely.)

## Validate the cask locally

```bash
brew audit --cask --new terminal-screensaver
brew style Casks/terminal-screensaver.rb
```
