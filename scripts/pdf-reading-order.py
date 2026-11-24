#!/usr/bin/env python3
"""Print the headings and figures of a tagged PDF's structure tree, in order.

Usage: scripts/pdf-reading-order.py <file.pdf>
One line per heading element (H, H1-H6), with its level and the text of its
subtree as `pdfinfo -struct-text` gives it ("H1 Jane Doe"), and per Figure,
with its alternative text in brackets ("Figure [Photo of Jane Doe]"). This
is the order in which assistive technology reads them. Used by
scripts/check-pdf.sh to compare it with the expected reading order.
"""
import re
import subprocess
import sys

ELEMENT = re.compile(r"^( *)(\w+) <")
FIGURE = re.compile(r'^ *Figure <[^>]*> \["(.*)"\]')
TEXT = re.compile(r'^( *)"(.*)"$')


def main() -> int:
    out = subprocess.run(["pdfinfo", "-struct-text", sys.argv[1]],
                         capture_output=True, text=True, check=True).stdout
    heading = None  # [indent, level, texts]
    for line in out.splitlines() + [""]:
        element, text = ELEMENT.match(line), TEXT.match(line)
        indent = len((element or text).group(1)) if element or text else -1
        if heading and indent <= heading[0] and not (text and indent > heading[0]):
            print(heading[1], " ".join(" ".join(heading[2]).split()))
            heading = None
        figure = FIGURE.match(line)
        if figure:
            print("Figure", f"[{figure.group(1)}]")
        if heading and text:
            heading[2].append(text.group(2))
        elif element and re.fullmatch(r"H[1-6]?", element.group(2)):
            heading = [indent, element.group(2), []]
    return 0


if __name__ == "__main__":
    sys.exit(main())
