#!/usr/bin/env python3
"""Check theme colours for WCAG 2.2 contrast (4.5:1, level AA, normal text).

Success criterion 1.4.3: theme colours are used for text such as names,
headings and dates. In each src/*.sty:
- a line "% contrast: <text> on <background>" declares a pair to check,
  with colours defined by \\definecolor {<name>} {HTML} {<hex>}, or white or
  black. A colour with declared pairs is checked against those only;
- a colour that is a declared background only (a fill) is not text;
- every other colour is checked as text on a white page.
Usage: scripts/check-contrast.py   (exit status 1 if any pair fails)
"""
import pathlib
import re
import sys

MINIMUM = 4.5
DEFINE = re.compile(r"\\definecolor\s*\{\s*([\w-]+)\s*\}\s*\{\s*HTML\s*\}\s*\{\s*([0-9A-Fa-f]{6})\s*\}")
PAIR = re.compile(r"^%\s*contrast:\s*([\w-]+)\s+on\s+([\w-]+)\s*$", re.M)
BASIC = {"white": "FFFFFF", "black": "000000"}


def luminance(hex_colour: str) -> float:
    """Relative luminance (WCAG 2.2 definition)."""
    def channel(c: float) -> float:
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (channel(int(hex_colour[i:i + 2], 16) / 255) for i in (0, 2, 4))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def ratio(a: str, b: str) -> float:
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def main() -> int:
    root = pathlib.Path(__file__).resolve().parent.parent
    status = 0
    for sty in sorted(root.glob("src/*.sty")):
        text = sty.read_text(encoding="utf-8")
        colours = dict(BASIC, **dict(DEFINE.findall(text)))
        pairs = PAIR.findall(text)
        for fg, bg in pairs:
            if fg not in colours or bg not in colours:
                print(f"FAIL  {sty.name}: unknown colour in '{fg} on {bg}'")
                status = 1
        texts = {fg for fg, _ in pairs}
        fills = {bg for _, bg in pairs} - texts
        checks = [p for p in pairs if p[0] in colours and p[1] in colours]
        checks += [(name, "white") for name, _ in DEFINE.findall(text)
                   if name not in texts and name not in fills]
        for fg, bg in checks:
            r = ratio(colours[fg], colours[bg])
            ok = r >= MINIMUM
            print(f"{'OK  ' if ok else 'FAIL'}  {sty.name}: {fg} on {bg} {r:.2f}:1")
            status |= not ok
    return status


if __name__ == "__main__":
    sys.exit(main())
