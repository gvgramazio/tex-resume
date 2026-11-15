#!/usr/bin/env sh
# Scaffold a vitae theme by copying an existing one.
# Usage: new-theme.sh <name> [base]   (name: lowercase letters only)
set -eu
cd "$(git rev-parse --show-toplevel)"

name=${1:?usage: new-theme.sh <name> [base]}
base=${2:-classic}
case $name in *[!a-z]*) echo "theme name must be [a-z]+" >&2; exit 2 ;; esac

src="src/vitaetheme$base.sty"
sty="src/vitaetheme$name.sty"
ex="examples/theme-$name.tex"
lvt="testfiles/theme-$name.lvt"
[ -f "$src" ] || { echo "base theme not found: $src" >&2; exit 1; }
for f in "$sty" "$ex" "$lvt"; do
  [ ! -e "$f" ] || { echo "already exists: $f" >&2; exit 1; }
done

# Theme file: rename the package, keep everything else as a starting point.
sed "s/vitaetheme$base/vitaetheme$name/g" "$src" >"$sty"

# Example: reuse the base theme's example if present, else a minimal one.
if [ -f "examples/theme-$base.tex" ]; then
  sed "s/\\\\usetheme{$base}/\\\\usetheme{$name}/" "examples/theme-$base.tex" >"$ex"
else
  printf '%% Example for the %s theme (dummy content only).\n\\documentclass{vitae}\n\\usetheme{%s}\n\\name{Jane}{Doe}\n\\begin{document}\n\\makeheader\n\\end{document}\n' "$name" "$name" >"$ex"
fi

# Test: the theme loads and typesets a header and an entry.
cat >"$lvt" <<EOF
% Theme $name: loads and typesets a header and an entry without errors.
\\documentclass{vitae}
\\usetheme{$name}
\\input{regression-test}
\\name{Jane}{Doe}
\\begin{document}
\\START
\\makeheader
\\cventry{title=Lorem, org=Ipsum, start=2020, end=2021}{Dolor sit amet.}
\\TYPE{theme $name ok}
\\END
EOF

echo "created: $sty $ex $lvt"
