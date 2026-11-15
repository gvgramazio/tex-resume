#!/usr/bin/env sh
# Write a JUnit XML report of the last `l3build check` run to stdout.
# One test case per test file and engine: passed, failed (with its diff)
# or errored (no log: the test never ran).
# Usage: scripts/junit.sh > build/test/junit.xml
set -eu
cd "$(dirname "$0")/.."

# Engines as configured in build.lua: checkengines = {"pdftex", ...}
engines=$(sed -n 's/^checkengines *= *{\(.*\)}.*/\1/p' build.lua | tr -d '"' | tr ',' ' ')
dir=build/test
tests=0 failures=0 errors=0
cases=$(mktemp)
trap 'rm -f "$cases"' EXIT

for lvt in testfiles/*.lvt; do
  name=$(basename "$lvt" .lvt)
  for e in $engines; do
    tests=$((tests + 1))
    printf '  <testcase classname="%s" name="%s"' "$e" "$name" >>"$cases"
    if [ -f "$dir/$name.$e.diff" ]; then
      failures=$((failures + 1))
      # The diff goes in CDATA; a literal "]]>" must be split across sections.
      {
        printf '>\n    <failure message="log differs from %s.tlg"><![CDATA[' "$name"
        sed 's/]]>/]]]]><![CDATA[>/g' "$dir/$name.$e.diff"
        printf ']]></failure>\n  </testcase>\n'
      } >>"$cases"
    elif [ -f "$dir/$name.$e.log" ]; then
      printf '/>\n' >>"$cases"
    else
      errors=$((errors + 1))
      printf '>\n    <error message="test did not run"/>\n  </testcase>\n' >>"$cases"
    fi
  done
done

printf '<?xml version="1.0" encoding="UTF-8"?>\n'
printf '<testsuite name="l3build" tests="%d" failures="%d" errors="%d">\n' \
  "$tests" "$failures" "$errors"
cat "$cases"
printf '</testsuite>\n'
