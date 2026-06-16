# Releasing Limpet to the tap

The formula points at a versioned source tarball and pins its `sha256`. Until a
real release exists, `Formula/limpet.rb` has a placeholder hash and **`brew
install` will fail the checksum**. Do this once per version.

## 1. Tag and release the app repo (`georgeolaru/limpet`)

```bash
cd /path/to/limpet
git tag v1.0.0
git push origin v1.0.0
gh release create v1.0.0 --title "Limpet 1.0.0" --generate-notes
```

GitHub then serves an auto-generated source tarball at the URL the formula uses:
`https://github.com/georgeolaru/limpet/archive/refs/tags/v1.0.0.tar.gz`

## 2. Get the sha256

```bash
curl -sL https://github.com/georgeolaru/limpet/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
```

Paste that hash into `Formula/limpet.rb` (`sha256 "..."`). The `url` interpolates
`#{version}`, so a version bump is a one-line change to `version`.

## 3. Test the formula locally before pushing the tap

```bash
# From a clone of the homebrew-tap repo:
brew install --build-from-source --verbose ./Formula/limpet.rb
brew test limpet
brew audit --strict --formula limpet     # style/sanity (some tap warnings are OK)
brew services start limpet
limpet --status
```

## 4. Push the tap

Commit `Formula/limpet.rb` to `github.com/georgeolaru/homebrew-tap`. Users get
the new version with `brew update && brew upgrade limpet`.

## Bumping later versions (automated)

After you cut a new `vX.Y.Z` release on `georgeolaru/limpet`, the formula updates
itself — you don't touch `version`/`sha256` by hand:

- **`.github/workflows/update-formula.yml`** runs `.github/scripts/update_formula.py`,
  which reads the release tag, computes the source-tarball `sha256`, rewrites
  `Formula/limpet.rb`, and commits. It's a no-op when already current.
- **Triggers:** a daily `schedule` (auto, ≤24 h lag) and manual
  `workflow_dispatch` (Actions tab → *Update Limpet formula* → optionally pin a
  tag) for an instant bump.
- **No secrets to configure:** it reads Limpet's public releases and writes to
  this tap with the built-in `GITHUB_TOKEN`.

To make it instant on every release, have the limpet release workflow call
`gh workflow run update-formula.yml -R georgeolaru/homebrew-tap` (needs a PAT).

Manual fallback (if you ever bypass the workflow): bump `version` + `sha256` in
`Formula/limpet.rb` per steps 1–2 above and push.

## TODO before the first real release

- [x] Add a `LICENSE` file to the limpet repo (MIT, matches the formula).
- [x] Inaugural version `v1.0.0` released; formula `sha256` pinned.
- [x] Created the `georgeolaru/homebrew-tap` repo and pushed this folder.
