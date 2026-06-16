# =============================================================================
# Pending its first SIGNED release. The version/sha256 below are placeholders.
#
# A Cask must point at a code-signed + notarized .app (Homebrew rejects casks
# that fail Gatekeeper). Produce one with `release-app.sh` in the limpet repo:
# it builds a universal Limpet.app, signs + notarizes + staples it, and emits
# Limpet-macos-universal-<version>.zip. Attach that to the matching GitHub
# release; the tap's auto-bump workflow then fills version + sha256 here.
# Until a signed zip exists, this cask won't install — use install.sh meanwhile.
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
