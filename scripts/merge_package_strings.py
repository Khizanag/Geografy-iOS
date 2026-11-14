#!/usr/bin/env python3
"""Copy every package's strings and translations into the app's String Catalog.

SwiftUI looks a `Text("…")`, `Button("…")`, or `.navigationTitle("…")` key up in the app's main
bundle unless the call names `bundle: .module`, and most package code can't: `Button` and
`navigationTitle` take no bundle. So a translation that lives only in a package's catalog never
reaches the screen. This makes the app catalog hold every package key too.

- A key the app catalog lacks is added with its translations, marked `"extractionState": "manual"`
  so Xcode keeps it although no app source uses it, and without a generated symbol: no app code
  refers to it, and similar keys ("Correct", "Correct!") would collide.
- A key the app catalog has gains any language it's missing; its existing translations win.

Run after translating, then commit the app catalog with the package catalogs:
    python3 scripts/merge_package_strings.py
Running it again changes nothing.
"""

import glob
import json
import os
import re

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP_CATALOG = os.path.join(REPO, "Geografy/Resource/Localizable.xcstrings")
PLACEHOLDER = re.compile(r"%(?:\d+\$)?(?:lld|ld|d|@|f|\.\d+f)|%%")


def has_words(key):
    """Keys of only placeholders and symbols need no translation, and the app catalog can't name a symbol for them."""
    return any(character.isalpha() for character in PLACEHOLDER.sub("", key))


def package_catalogs():
    patterns = ["Geografy/Feature/*/Sources/*/Resources/*.xcstrings", "Package/*/Sources/*/Resources/*.xcstrings"]
    return sorted(path for pattern in patterns for path in glob.glob(os.path.join(REPO, pattern)))


def write(path, catalog):
    with open(path, "w", encoding="utf-8") as output:
        output.write(json.dumps(catalog, indent=2, separators=(",", " : "), ensure_ascii=False, sort_keys=True) + "\n")


def main():
    app = json.load(open(APP_CATALOG, encoding="utf-8"))
    strings = app["strings"]
    added = filled = 0
    for path in package_catalogs():
        for key, entry in json.load(open(path, encoding="utf-8"))["strings"].items():
            if entry.get("extractionState") == "stale" or entry.get("shouldTranslate") is False or not has_words(key):
                continue
            localizations = entry.get("localizations", {})
            if key not in strings:
                strings[key] = {"extractionState": "manual", "generatesSymbol": False}
                if entry.get("comment"):
                    strings[key]["comment"] = entry["comment"]
                if localizations:
                    strings[key]["localizations"] = localizations
                added += 1
                continue
            target = strings[key].setdefault("localizations", {})
            for language, value in localizations.items():
                if language not in target:
                    target[language] = value
                    filled += 1
    for key, entry in list(strings.items()):
        if entry.get("extractionState") != "manual":
            continue
        if has_words(key):
            entry["generatesSymbol"] = False
        else:
            del strings[key]
    write(APP_CATALOG, app)
    print(f"added {added} keys, filled {filled} translations")


if __name__ == "__main__":
    main()
