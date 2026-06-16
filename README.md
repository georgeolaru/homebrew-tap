# georgeolaru/homebrew-tap

A [Homebrew tap](https://docs.brew.sh/Taps) for [Limpet](https://github.com/georgeolaru/limpet) —
keep your Mac online by failing over to your phone's hotspot, automatically.

> **This directory is staging.** A tap must be its *own* GitHub repo named
> `homebrew-<name>`. Push the contents of this folder to
> **`github.com/georgeolaru/homebrew-tap`**, then the commands below work.
> (`brew install georgeolaru/tap/...` is shorthand for the `homebrew-tap` repo.)

## Install (after the tap repo is pushed and v1.0.0 is released)

```bash
brew install georgeolaru/tap/limpet   # taps automatically, then installs
brew services start limpet            # start the agent (per-user, no sudo)
```

`brew services` loads Limpet into your user LaunchAgent domain — the same place
`install.sh` puts it — so it reaches the Keychain and manages Wi-Fi without
`sudo`. Then do the one-time setup `brew info limpet` prints (config, Keychain
password, one manual hotspot connection).

## What ships where — and why (the CodexBar model)

[steipete/homebrew-tap](https://github.com/steipete/homebrew-tap) ships CodexBar
as **two** packages: a **Formula** for the CLI and a **Cask** for the notarized
menu-bar app. Limpet follows the same split, with one difference driven by code
signing:

| Piece | Mechanism | Status |
|---|---|---|
| Daemon + CLI (`limpet`) | **`Formula/limpet.rb`** (+ `brew services`) | **Ready** — no Apple Developer account needed. |
| Menu-bar `Limpet.app` | **`Casks/limpet.rb`** | **Template only** — Homebrew requires casks to be **signed + notarized**. Needs an Apple Developer ID. |

The reliability engine (the daemon) is fully Homebrew-native today. The menu-bar
app is an *unsigned GUI app*, which is exactly what a Cask is for — but Homebrew
won't host a non-notarized cask. Until Limpet is notarized, install the menu-bar
app from the repo's `install.sh` (it compiles locally with `swiftc`, so
Gatekeeper allows it), or run daemon-only via this formula.

### Two tracks

- **Now:** `Formula/limpet.rb` → `brew install` + `brew services` for the agent.
  Menu-bar app via `install.sh`.
- **Later (full CodexBar parity):** get an Apple Developer ID, sign + notarize
  `Limpet.app` (see CodexBar's `Scripts/sign-and-notarize.sh`), publish a
  release zip, fill in `Casks/limpet.rb`, then `brew install --cask
  georgeolaru/tap/limpet`.

## Files

| File | Role |
|---|---|
| `Formula/limpet.rb` | The daemon + CLI formula. **Set `sha256` after the first release.** |
| `Casks/limpet.rb` | Template for the future notarized menu-bar app cask. |
| `RELEASING.md` | How to cut a release and bump the formula. |
