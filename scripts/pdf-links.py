#!/usr/bin/env python3
"""Print the action type of every link in a PDF, one per line (URI, GoToR, ...).

Usage: scripts/pdf-links.py <file.pdf>
Reads plain and Flate-compressed objects; enough for pdfTeX, XeTeX and LuaTeX
output. Used by scripts/check-pdf.sh: web links must be URI actions.
"""
import re
import sys
import zlib


def main() -> int:
    data = open(sys.argv[1], "rb").read()
    parts = [data]
    for match in re.finditer(rb"stream\r?\n(.*?)endstream", data, re.S):
        try:
            parts.append(zlib.decompressobj().decompress(match.group(1)))
        except zlib.error:
            pass
    for match in re.finditer(rb"/S\s*/(URI|GoToR|GoToE|Launch)\b", b"\n".join(parts)):
        print(match.group(1).decode())
    return 0


if __name__ == "__main__":
    sys.exit(main())
