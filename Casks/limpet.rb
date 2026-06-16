# =============================================================================
# The menu-bar app — code-signed + notarized for distribution outside the Mac
# App Store. Built by `release-app.sh` in the limpet repo (universal build →
# sign → notarize → staple → zip). On each signed release, attach the
# Limpet-macos-universal-<version>.zip asset; the tap's auto-bump workflow then
# updates the version + sha256 below.
# =============================================================================
cask "limpet" do
  version "1.0.0"
  sha256 "c38cf9c7da494f98006a1e28b7ff36d2c1cefddab4495d212e7cb6034b8b9b57"

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
