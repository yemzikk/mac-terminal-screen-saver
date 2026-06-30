cask "terminal-screensaver" do
  version "1.0"

  # Update this after each release: shasum -a 256 TerminalScreenSaver.saver.zip
  # For a personal tap you may instead use `sha256 :no_check` (skips verification).
  sha256 "REPLACE_WITH_SHA256_OF_RELEASE_ZIP"

  url "https://github.com/yemzikk/mac-terminal-screen-saver/releases/download/v#{version}/TerminalScreenSaver.saver.zip"
  name "Terminal Screen Saver"
  desc "Animated fake-terminal macOS screen saver"
  homepage "https://github.com/yemzikk/mac-terminal-screen-saver"

  # The bundle is ad-hoc signed but not notarized. Users should install with
  # `--no-quarantine` so Gatekeeper doesn't block the saver:
  #   brew install --cask --no-quarantine yemzikk/tap/terminal-screensaver
  screen_saver "TerminalScreenSaver.saver"

  zap trash: "~/Library/Screen Savers/TerminalScreenSaver.saver"
end
