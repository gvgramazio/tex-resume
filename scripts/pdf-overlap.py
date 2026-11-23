#!/usr/bin/env python3
"""Print the words that overlap other words in a PDF (overprinted text).

Usage: scripts/pdf-overlap.py <file.pdf>
Reads word boxes from `pdftotext -bbox`; two words overlap if their boxes
share more than half the area of the smaller one. Prints one line per
overlapping pair ("page N: 'word' / 'word'"), nothing for a clean PDF.
Used by scripts/check-pdf.sh on layouts with columns.
"""
import html
import re
import subprocess
import sys

WORD = re.compile(
    r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">(.*?)</word>')


def main() -> int:
    out = subprocess.run(["pdftotext", "-bbox", sys.argv[1], "-"],
                         capture_output=True, text=True, check=True).stdout
    for n, page in enumerate(out.split("<page ")[1:], start=1):
        words = [(*map(float, m.groups()[:4]), html.unescape(m.group(5)))
                 for m in WORD.finditer(page)]
        words.sort(key=lambda w: w[1])
        for i, a in enumerate(words):
            for b in words[i + 1:]:
                if b[1] >= a[3]:
                    break
                w = min(a[2], b[2]) - max(a[0], b[0])
                h = min(a[3], b[3]) - max(a[1], b[1])
                small = min((a[2] - a[0]) * (a[3] - a[1]), (b[2] - b[0]) * (b[3] - b[1]))
                if w > 0 and h > 0 and w * h > 0.5 * small:
                    print(f"page {n}: {a[4]!r} / {b[4]!r}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
