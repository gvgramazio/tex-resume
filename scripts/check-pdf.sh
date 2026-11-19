#!/usr/bin/env sh
# Check built examples (scripts/build.sh) for accessibility and clean text.
# Usage: scripts/check-pdf.sh [build/examples/<engine> ...]  (default: all)
# Needs pdftotext (poppler) and veraPDF; set VERAPDF to override the command
# (CI runs it in a container).
#   1. veraPDF: accessible.pdf must pass PDF/UA-2, accessible-ua1.pdf PDF/UA-1.
#   2. Text extraction, as applicant-tracking systems read it: the header of
#      every showcase must extract as the exact contact line, so any icon
#      junk, lost character or missing label fails the check.
#   3. Links: every link in a showcase must be a web link (URI action), never
#      a file link (GoToR, Launch), and the showcase header has five of them.
set -eu
cd "$(dirname "$0")/.."
VERAPDF=${VERAPDF:-verapdf}
status=0
fail() { echo "FAIL  $*"; status=1; }

# Expected header text: labelled on pdfTeX/LuaTeX; XeTeX hides icons only.
contacts='jane.doe@example.com +00 000 000 0000 1 Example Street, Springfield example.com/~jane jane-doe-example jdoe-example 0000-0000-0000-0000'
labelled='Email: jane.doe@example.com Phone: +00 000 000 0000 Address: 1 Example Street, Springfield Website: example.com/~jane LinkedIn: jane-doe-example GitHub: jdoe-example ORCID: 0000-0000-0000-0000'

[ $# -gt 0 ] || set -- build/examples/*
for dir in "$@"; do
  e=$(basename "$dir")

  # 1. PDF/UA validation of the tagged examples.
  for pair in accessible:ua2 accessible-ua1:ua1; do
    f="$dir/${pair%%:*}.pdf"
    [ -f "$f" ] || continue
    if $VERAPDF -f "${pair##*:}" --format text "$f" | grep -q '^PASS'; then
      echo "OK    $e $f (${pair##*:})"
    else
      fail "$e $f (${pair##*:})"
      $VERAPDF -f "${pair##*:}" --format xml "$f" \
        | grep -o '<description>[^<]*</description>' | sort -u
    fi
  done

  # 2. Text extraction: whitespace normalised, contact separators (" ;")
  #    dropped, then the contact line must appear verbatim.
  if [ "$e" = xe ]; then want=$contacts; else want=$labelled; fi
  for f in "$dir"/theme-*.pdf "$dir"/accessible*.pdf; do
    [ -f "$f" ] || continue
    text=$(pdftotext "$f" - | tr '\n\f' '  ' | tr -s ' ' | sed 's/ ;//g')
    case $text in
      *"$want"*) echo "OK    $e $f (text)" ;;
      *) fail "$e $f (text): expected \"$want\""
         printf '      got: %.300s\n' "$text" ;;
    esac

    # 3. Link actions: all URI, at least the five contact links.
    actions=$(scripts/pdf-links.py "$f" | sort | uniq -c | tr -s ' ' | tr '\n' ',')
    uri=$(scripts/pdf-links.py "$f" | grep -c '^URI$' || true)
    other=$(scripts/pdf-links.py "$f" | grep -vc '^URI$' || true)
    if [ "$other" -eq 0 ] && [ "$uri" -ge 5 ]; then
      echo "OK    $e $f (links)"
    else
      fail "$e $f (links): expected only URI actions, at least 5; got:$actions"
    fi
  done
done
exit $status
