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

## Bumping later versions

Repeat 1–2 with the new tag, update `version` + `sha256`, push. To automate it,
mirror CodexBar's `.github/workflows/update-formula.yml` +
`.github/scripts/update_formula.py`, which rewrite the formula's `version`/`sha256`
from a release event.

## TODO before the first real release

- [x] Add a `LICENSE` file to the limpet repo (MIT, matches the formula).
- [x] Inaugural version `v1.0.0` released; formula `sha256` pinned.
- [x] Created the `georgeolaru/homebrew-tap` repo and pushed this folder.
