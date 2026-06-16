# =============================================================================
# TEMPLATE — NOT YET USABLE.
#
# Modeled on steipete/homebrew-tap Casks/codexbar.rb. A Cask distributes the
# prebuilt menu-bar .app, but Homebrew requires casks to be code-signed AND
# notarized (the audit removes non-notarized casks by Sept 2026). To enable
# this you need:
#   1. An Apple Developer ID ($99/yr).
#   2. A signed + notarized, stapled Limpet.app zipped into a GitHub release,
#      e.g. Limpet-macos-universal-<version>.zip  (see CodexBar's
#      Scripts/sign-and-notarize.sh for the pattern).
#   3. The real version + sha256 filled in below.
#
# Until then, the menu-bar app installs via the repo's install.sh (it compiles
# locally with swiftc, so Gatekeeper doesn't block a local build).
# =============================================================================
cask "limpet" do
  version "1.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/georgeolaru/limpet/releases/download/v#{version}/Limpet-macos-universal-#{version}.zip",
      verified: "github.com/georgeolaru/limpet/"
  name "Limpet"
  desc "Menu-bar companion that keeps your Mac online via your phone's hotspot"
  homepage "https://github.com/georgeolaru/limpet"

  depends_on macos: :ventura # README states macOS 13+
  depends_on formula: "limpet" # the daemon/CLI this UI drives

  app "Limpet.app"

  # Leaves config + logs in place; remove them too on `brew uninstall --zap`.
  zap trash: [
    "~/.config/limpet",
    "~/Library/Logs/limpet.log",
    "~/Library/Logs/limpet.log.1",
    "~/Library/LaunchAgents/com.georgeolaru.limpet.menu.plist",
  ]
end
