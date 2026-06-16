#!/usr/bin/env python3
"""Bump Formula/limpet.rb to a georgeolaru/limpet release.

Limpet's formula is the simplest shape: one `version` and one `sha256` for the
GitHub source tarball. This rewrites both to match a release tag (default: the
latest one). It is a no-op when the formula is already current, so it is safe to
run on a schedule. Standard library only — no pip installs in CI.
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
FORMULA = pathlib.Path(__file__).resolve().parents[2] / "Formula" / "limpet.rb"
USER_AGENT = "georgeolaru-homebrew-tap-updater"


def _open(url: str, accept: str):
    headers = {"User-Agent": USER_AGENT, "Accept": accept}
    token = os.environ.get("GITHUB_TOKEN")
    if token:  # public reads work unauthenticated too, but the token lifts rate limits
        headers["Authorization"] = f"Bearer {token}"
    return urllib.request.urlopen(urllib.request.Request(url, headers=headers))


def latest_tag() -> str:
    with _open(f"https://api.github.com/repos/{REPO}/releases/latest",
               "application/vnd.github+json") as resp:
        return json.load(resp)["tag_name"]


def sha256_of(url: str) -> str:
    digest = hashlib.sha256()
    with _open(url, "application/octet-stream") as resp:
        while chunk := resp.read(1 << 20):
            digest.update(chunk)
    return digest.hexdigest()


def replace_one(text: str, pattern: str, replacement: str, what: str) -> str:
    new, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        sys.exit(f"expected exactly one {what} line in {FORMULA.name}, found {count}")
    return new


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", help="release tag, e.g. v1.2.0 (default: latest release)")
    tag = parser.parse_args().tag or latest_tag()
    version = tag.lstrip("v")
    tarball = f"https://github.com/{REPO}/archive/refs/tags/{tag}.tar.gz"

    text = FORMULA.read_text()
    current = re.search(r'^\s*version "([^"]+)"', text, re.MULTILINE)
    if current and current.group(1) == version:
        print(f"already at {version}; nothing to do")
        return

    sha = sha256_of(tarball)
    text = replace_one(text, r'^(\s*)version "[^"]+"', rf'\g<1>version "{version}"', "version")
    text = replace_one(text, r'^(\s*)sha256 "[^"]+"', rf'\g<1>sha256 "{sha}"', "sha256")
    FORMULA.write_text(text)
    print(f"bumped limpet -> {version} ({sha})")


if __name__ == "__main__":
    main()
