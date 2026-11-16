#!/usr/bin/env python3
"""Check theme colours for WCAG 2.2 contrast against a white page.

Every \\definecolor {<name>} {HTML} {<hex>} in src/*.sty must reach 4.5:1
(success criterion 1.4.3, level AA, normal-size text): theme colours are
used for text such as names, headings and dates.
Usage: scripts/check-contrast.py   (exit status 1 if any colour fails)
"""
import pathlib
import re
import sys

MINIMUM = 4.5
DEFINE = re.compile(r"\\definecolor\s*\{\s*([\w-]+)\s*\}\s*\{\s*HTML\s*\}\s*\{\s*([0-9A-Fa-f]{6})\s*\}")


def luminance(hex_colour: str) -> float:
    """Relative luminance (WCAG 2.2 definition)."""
    def channel(c: float) -> float:
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (channel(int(hex_colour[i:i + 2], 16) / 255) for i in (0, 2, 4))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def main() -> int:
    root = pathlib.Path(__file__).resolve().parent.parent
    status = 0
    for sty in sorted(root.glob("src/*.sty")):
        for name, hex_colour in DEFINE.findall(sty.read_text(encoding="utf-8")):
            ratio = 1.05 / (luminance(hex_colour) + 0.05)
            ok = ratio >= MINIMUM
            print(f"{'OK  ' if ok else 'FAIL'}  {sty.name}: {name} #{hex_colour} {ratio:.2f}:1")
            status |= not ok
    return status


if __name__ == "__main__":
    sys.exit(main())
