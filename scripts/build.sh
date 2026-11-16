#!/usr/bin/env sh
# Compile example documents into build/examples/<engine>/<name>.pdf.
# Usage: scripts/build.sh [-e "pdf xe lua"] [-s] [file.tex ...]
#   -e  engines to use (default: all three)
#   -s  strict: fail on any LaTeX/package warning or overfull box
# With no files, every examples/*.tex is built.
set -eu
cd "$(dirname "$0")/.."

engines="pdf xe lua"
strict=0
while getopts "e:s" opt; do
  case $opt in
    e) engines=$OPTARG ;;
    s) strict=1 ;;
    *) echo "usage: $0 [-e engines] [-s] [file.tex ...]" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || set -- examples/*.tex

# Resolve the class and themes from src/ without installing them.
TEXINPUTS="$PWD/src//:${TEXINPUTS:-}"
export TEXINPUTS

status=0
for e in $engines; do
  case $e in
    pdf) flag=-pdf ;;
    xe)  flag=-xelatex ;;
    lua) flag=-lualatex ;;
    *)   echo "unknown engine: $e" >&2; exit 2 ;;
  esac
  out="$PWD/build/examples/$e"
  mkdir -p "$out"
  for f in "$@"; do
    # A "% engines: <list>" line in the first five lines limits the engines.
    only=$(sed -n '1,5s/^% engines: *//p' "$f")
    if [ -n "$only" ]; then
      case " $only " in *" $e "*) ;; *) echo "SKIP  $e $f"; continue ;; esac
    fi
    name=$(basename "$f" .tex)
    log="$out/$name.log"
    # -cd: run from the file's directory so relative \input paths resolve.
    if latexmk "$flag" -cd -silent -interaction=nonstopmode -halt-on-error \
        -file-line-error -outdir="$out" "$f" >/dev/null 2>&1; then
      # Warnings are listed always; in strict mode they also fail the build.
      if grep -nE "Warning|Overfull" "$log" >"$out/$name.warnings"; then
        echo "WARN  $e $f (see $out/$name.warnings)"
        cat "$out/$name.warnings"
        [ $strict -eq 0 ] || status=1
      else
        echo "OK    $e $f"
      fi
    else
      echo "FAIL  $e $f"
      grep -nE "^(.*:[0-9]+:|!)" "$log" | head -20 || true
      status=1
    fi
  done
done
exit $status
