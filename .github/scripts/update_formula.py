#!/usr/bin/env python3
"""Bump Formula/limpet.rb (and Casks/limpet.rb) to a georgeolaru/limpet release.

- Formula: always pinned to the release's source tarball (version + sha256).
- Cask: pinned only when the release carries a signed, notarized
  `Limpet-macos-universal-<version>.zip` asset (produced by the limpet repo's
  release-app.sh). Until that asset exists, the cask is left untouched.

No-op when already current, so it's safe to run on a schedule. Standard library
only — no pip installs in CI.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import re
import sys
import urllib.request

REPO = "georgeolaru/limpet"
ROOT = pathlib.Path(__file__).resolve().parents[2]
FORMULA = ROOT / "Formula" / "limpet.rb"
CASK = ROOT / "Casks" / "limpet.rb"
USER_AGENT = "georgeolaru-homebrew-tap-updater"


def _open(url: str, accept: str):
    headers = {"User-Agent": USER_AGENT, "Accept": accept}
    token = os.environ.get("GITHUB_TOKEN")
    if token:  # public reads work unauthenticated too, but the token lifts rate limits
        headers["Authorization"] = f"Bearer {token}"
    return urllib.request.urlopen(urllib.request.Request(url, headers=headers))


def get_release(tag: str | None) -> dict:
    suffix = f"tags/{tag}" if tag else "latest"
    with _open(f"https://api.github.com/repos/{REPO}/releases/{suffix}",
               "application/vnd.github+json") as resp:
        return json.load(resp)


def sha256_of(url: str) -> str:
    digest = hashlib.sha256()
    with _open(url, "application/octet-stream") as resp:
        while chunk := resp.read(1 << 20):
            digest.update(chunk)
    return digest.hexdigest()


def needs_update(path: pathlib.Path, version: str) -> bool:
    text = path.read_text()
    ver = re.search(r'^\s*version "([^"]+)"', text, re.MULTILINE)
    sha = re.search(r'^\s*sha256 "([^"]+)"', text, re.MULTILINE)
    is_placeholder = bool(sha) and set(sha.group(1)) == {"0"}
    return not (ver and ver.group(1) == version) or is_placeholder


def write_pin(path: pathlib.Path, version: str, sha: str, label: str) -> None:
    text = path.read_text()
    for pattern, replacement, what in (
        (r'^(\s*)version "[^"]+"', rf'\g<1>version "{version}"', "version"),
        (r'^(\s*)sha256 "[^"]+"', rf'\g<1>sha256 "{sha}"', "sha256"),
    ):
        text, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
        if count != 1:
            sys.exit(f"expected exactly one {what} line in {path.name}, found {count}")
    path.write_text(text)
    print(f"{label}: bumped to {version} ({sha})")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", help="release tag, e.g. v1.2.0 (default: latest release)")
    release = get_release(parser.parse_args().tag)
    tag = release["tag_name"]
    version = tag.lstrip("v")

    # Formula — pinned to the source tarball.
    if needs_update(FORMULA, version):
        tarball = f"https://github.com/{REPO}/archive/refs/tags/{tag}.tar.gz"
        write_pin(FORMULA, version, sha256_of(tarball), "formula")
    else:
        print(f"formula: already at {version}; nothing to do")

    # Cask — pinned only if the release carries the signed app zip.
    asset_name = f"Limpet-macos-universal-{version}.zip"
    asset = next((a for a in release.get("assets", []) if a["name"] == asset_name), None)
    if not asset:
        print(f"cask: no {asset_name} asset on {tag}; left unchanged")
    elif needs_update(CASK, version):
        write_pin(CASK, version, sha256_of(asset["browser_download_url"]), "cask")
    else:
        print(f"cask: already at {version}; nothing to do")


if __name__ == "__main__":
    main()
