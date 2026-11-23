#!/usr/bin/env python3
"""Print every key in a PDF that upload filters treat as active content.

Usage: scripts/pdf-active.py <file.pdf>
Prints one key per occurrence (OpenAction, JavaScript, ...); no output means
none. EmbeddedFiles is the name tree of attachments; tagpdf's associated
files (/AF streams of /Type /EmbeddedFile) are not attachments and pass.
Reads plain and Flate-compressed objects, including object streams.
Used by scripts/check-pdf.sh: applicant tracking systems such as SAP
SuccessFactors reject a PDF that has any of them.
"""
import re
import sys
import zlib

KEYS = rb"OpenAction|AA|JS|JavaScript|Launch|EmbeddedFiles|RichMedia|AcroForm|XFA"


def main() -> int:
    data = open(sys.argv[1], "rb").read()
    parts = [data]
    for match in re.finditer(rb"stream\r?\n(.*?)endstream", data, re.S):
        try:
            parts.append(zlib.decompressobj().decompress(match.group(1)))
        except zlib.error:
            pass
    for match in re.finditer(rb"/(" + KEYS + rb")(?![^\s/<>\[\]()%{}])", b"\n".join(parts)):
        print(match.group(1).decode())
    return 0


if __name__ == "__main__":
    sys.exit(main())
