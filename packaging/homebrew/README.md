# Homebrew Tap Setup

This directory holds the Homebrew Cask for distributing the screen saver without a
paid Apple Developer ID. The bundle is ad-hoc signed but **not notarized**, so it
can't go in the main `homebrew/cask` repo — it must live in your own tap.

`terminal-screensaver.rb` in this directory is the **source of truth**. The
release workflow renders it into the tap on every tagged release (see below), so
you normally never edit the tap repo by hand.

## One-time setup

**1. Create the tap repo.** Homebrew taps must be named `homebrew-<name>`. Create
an empty repo called `homebrew-tap` under your GitHub account (a `Casks/` folder
and the cask file are created automatically on the first release).

**2. Create a token for CI to push to it.** In GitHub → Settings → Developer
settings → **Fine-grained personal access tokens**, create a token:
- **Repository access:** only `yemzikk/homebrew-tap`
- **Permissions:** Contents → **Read and write**

**3. Add it as a secret** on the `mac-terminal-screen-saver` repo:
Settings → Secrets and variables → Actions → New repository secret, named
**`HOMEBREW_TAP_TOKEN`**, value = the token from step 2.

That's it. The `update-tap` job in `.github/workflows/release.yml` skips silently
until this secret exists.

## Each release: fully automated

On every `v*` tag, the release workflow builds the bundle, publishes the release,
then computes the zip's `sha256`, substitutes it plus the version into this cask
template, and commits the result to `homebrew-tap/Casks/terminal-screensaver.rb`.

No manual checksum step. To do it by hand anyway (e.g. before CI is set up):

```bash
curl -sL -o /tmp/tss.zip \
  https://github.com/yemzikk/mac-terminal-screen-saver/releases/download/v1.0.3/TerminalScreenSaver.saver.zip
shasum -a 256 /tmp/tss.zip   # paste into sha256, set version to match the tag
```

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
