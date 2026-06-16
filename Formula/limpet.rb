# typed: false
# frozen_string_literal: true

# Limpet — keep your Mac online by failing over to your phone's hotspot.
#
# This formula ships the shell daemon + CLI and wires it into `brew services`
# (a per-user LaunchAgent, no sudo). The native menu-bar app is NOT installed
# here: it is an unsigned GUI app, which belongs in a Cask, and Homebrew now
# requires casks to be code-signed + notarized. See ../Casks/limpet.rb and the
# tap README for the menu-bar story.
class Limpet < Formula
  desc "Keep your Mac online by failing over to your phone's hotspot"
  homepage "https://github.com/georgeolaru/limpet"
  version "1.0.0"
  url "https://github.com/georgeolaru/limpet/archive/refs/tags/v#{version}.tar.gz"
  sha256 "9a4fd73a1ec69345bd797644562c873f4400b00c06bf4f0d9e1b9ec808def221"
  license "MIT"

  depends_on :macos

  def install
    # The daemon + CLI. Installed as the real script (not a wrapper) so the
    # `--help`/usage text, which reads "$0", resolves to this file.
    bin.install "limpet.sh" => "limpet"

    # Reference config only — Homebrew must never write to the user's $HOME at
    # install time. The daemon runs fine on built-in defaults; `limpet
    # --set-config KEY VALUE` (and the Settings UI) create ~/.config/limpet on
    # demand. Users can copy this as a starting point.
    pkgshare.install "config.example.sh"
  end

  # `brew services start limpet` (no sudo) loads this into gui/$(id -u),
  # the same per-user domain install.sh uses — so it can reach the Keychain
  # and manage Wi-Fi without elevated privileges.
  service do
    run ["/bin/bash", opt_bin/"limpet"]
    keep_alive true
    process_type :background
    log_path var/"log/limpet-agent.log"
    error_log_path var/"log/limpet-agent.err.log"
  end

  def caveats
    <<~EOS
      Start the background agent (per-user, no sudo):
        brew services start limpet

      One-time setup (see the repo README for details):
        1. Reference config lives at:
             #{opt_pkgshare}/config.example.sh
           Edit settings with the CLI (creates ~/.config/limpet/config.sh):
             limpet --set-config HOTSPOT_SSID "My iPhone"
           or copy the reference file there and edit it directly.
        2. Store the hotspot password in the Keychain:
             security add-generic-password -s "limpet-hotspot" \\
               -a "My iPhone" -w "HOTSPOT_PASSWORD" -U
        3. Connect to the hotspot manually once so macOS saves it.

      Check status / logs:
        limpet --status
        tail -f ~/Library/Logs/limpet.log

      Menu-bar app: not included in this formula (it's an unsigned GUI app).
      Install it from the repo's install.sh, or watch for a signed Cask.
    EOS
  end

  test do
    assert_match(/limpet/i, shell_output("#{bin}/limpet --help"))
  end
end
