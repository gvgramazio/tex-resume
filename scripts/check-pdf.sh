#!/usr/bin/env sh
# Check built examples (scripts/build.sh) for accessibility and clean text.
# Usage: scripts/check-pdf.sh [build/examples/<engine> ...]  (default: all)
# Needs pdftotext (poppler) and veraPDF; set VERAPDF to override the command
# (CI runs it in a container).
#   1. veraPDF: every example in the table below must pass each listed
#      profile (PDF/UA and PDF/A), on each engine that built it.
#   2. Text extraction, as applicant-tracking systems read it: the masthead of
#      every showcase and letter must extract as the exact contact line, so
#      any icon junk, lost character or missing label fails the check.
#   3. Links: every link in a showcase or letter must be a web link (URI
#      action), never a file link (GoToR, Launch), and the masthead has five.
#   4. Active content: no example may have a key that upload filters of
#      applicant-tracking systems reject (OpenAction, JavaScript, ...).
#   5. Aside column: in the aside stress examples, the first and last words
#      of the column extract exactly once (no part lost or printed twice).
#   6. Overprinting: in every example, no two words overlap on the page
#      (scripts/pdf-overlap.py), as a column printed over main would.
set -eu
cd "$(dirname "$0")/.."
VERAPDF=${VERAPDF:-verapdf}
status=0
fail() { echo "FAIL  $*"; status=1; }

# Expected header text: labelled on pdfTeX/LuaTeX; XeTeX hides icons only.
contacts='jane.doe@example.com +00 000 000 0000 1 Example Street, Springfield example.com/~jane jane-doe-example jdoe-example 0000-0000-0000-0000'
labelled='Email: jane.doe@example.com Phone: +00 000 000 0000 Address: 1 Example Street, Springfield Website: example.com/~jane LinkedIn: jane-doe-example GitHub: jdoe-example ORCID: 0000-0000-0000-0000'

# Example and the veraPDF profiles it must pass (comma-separated).
validations='
accessible       ua2
accessible-ua1   ua1
accessible-aside ua2
accessible-letter ua2
archival-a4f     4f,ua2
archival-a3a     3a,ua1
archival-a2a     2a,ua1
archival-a2u     2u
archival-a2b     2b
'

[ $# -gt 0 ] || set -- build/examples/*
for dir in "$@"; do
  e=$(basename "$dir")

  # 1. veraPDF validation (PDF/UA, PDF/A) of the examples in the table.
  echo "$validations" | while read -r name profiles; do
    f="$dir/$name.pdf"
    [ -n "$name" ] && [ -f "$f" ] || continue
    for p in $(echo "$profiles" | tr ',' ' '); do
      if $VERAPDF -f "$p" --format text "$f" | grep -q '^PASS'; then
        echo "OK    $e $f ($p)"
      else
        echo "FAIL  $e $f ($p)"
        $VERAPDF -f "$p" --format xml "$f" \
          | grep -o '<description>[^<]*</description>' | sort -u
      fi
    done
  done > "$dir/verapdf.out" 2>/dev/null
  cat "$dir/verapdf.out"
  ! grep -q '^FAIL' "$dir/verapdf.out" || status=1

  # 2. Text extraction: whitespace normalised, contact separators (" ;")
  #    dropped, then the contact line must appear verbatim.
  if [ "$e" = xe ]; then want=$contacts; else want=$labelled; fi
  for f in "$dir"/theme-*.pdf "$dir"/letter-*.pdf "$dir"/accessible*.pdf "$dir"/archival-*.pdf; do
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

  # 4. Active content (scripts/pdf-active.py), in every example. PDF/A-4f
  #    requires an attachment (LaTeX adds a placeholder), so it is exempt.
  for f in "$dir"/*.pdf; do
    [ -f "$f" ] && [ "$(basename "$f")" != archival-a4f.pdf ] || continue
    keys=$(scripts/pdf-active.py "$f" | sort -u | tr '\n' ' ')
    if [ -z "$keys" ]; then
      echo "OK    $e $f (active content)"
    else
      fail "$e $f (active content): $keys"
    fi
  done

  # 5. Aside column: each marker once, whitespace normalised.
  for f in "$dir"/stress-aside-*.pdf; do
    [ -f "$f" ] || continue
    text=$(pdftotext "$f" - | tr '\n\f' '  ' | tr -s ' ')
    for m in 'Aside start.' 'Aside end.'; do
      n=$(printf '%s' "$text" | grep -o "$m" | wc -l | tr -d ' ')
      if [ "$n" -eq 1 ]; then
        echo "OK    $e $f (aside: $m)"
      else
        fail "$e $f (aside): \"$m\" extracted $n times, expected once"
      fi
    done
  done

  # 6. Overprinting, in every example.
  for f in "$dir"/*.pdf; do
    [ -f "$f" ] || continue
    pairs=$(scripts/pdf-overlap.py "$f")
    if [ -z "$pairs" ]; then
      echo "OK    $e $f (no overprint)"
    else
      fail "$e $f (overprint): $(echo "$pairs" | wc -l | tr -d ' ') overlapping words"
      echo "$pairs" | head -3 | sed 's/^/      /'
    fi
  done
done
exit $status
