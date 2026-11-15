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
[ -f "$src" ] || { echo "base theme not found: $src" >&2; exit 1; }
for f in "$sty" "examples/theme-$name.tex" "examples/stress-$name.tex"; do
  [ ! -e "$f" ] || { echo "already exists: $f" >&2; exit 1; }
done

# Theme file: rename the package and its internal prefix, keep the rest.
sed -e "s/vitaetheme$base/vitaetheme$name/g" \
    -e "s/vitae $base theme/vitae $name theme/" \
    -e "s/__vitae_${base}_/__vitae_${name}_/g" "$src" >"$sty"

# Examples: the base theme's showcase and stress test, switched over.
for kind in theme stress; do
  sed -e "s/\\\\usetheme{$base}/\\\\usetheme{$name}/" \
      -e "s/the $base theme/the $name theme/" \
      "examples/$kind-$base.tex" >"examples/$kind-$name.tex"
done

echo "created: $sty examples/theme-$name.tex examples/stress-$name.tex"
