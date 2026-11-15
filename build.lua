-- l3build configuration for the vitae class.
-- Run `l3build check` for regression tests, `l3build tag X.Y.Z` to bump versions.

module = "vitae"

-- Sources: class and themes live in src/ and are installed as-is (no .dtx/.ins).
sourcefiledir = "src"
sourcefiles   = {"*.cls", "*.sty"}
installfiles  = {"*.cls", "*.sty"}
tagfiles      = {"*.cls", "*.sty"}

-- Tests: one .lvt per behaviour/edge case, checked on every supported engine.
testfiledir  = "testfiles"
checkengines = {"pdftex", "xetex", "luatex"}
stdengine    = "pdftex"
checkruns    = 1

-- Packaging: README and LICENSE ship with the CTAN/release zip.
textfiles = {"README.md", "LICENSE", "CHANGELOG.md"}

-- Rewrite `\ProvidesExpl...{name}{date}{version}` on `l3build tag`.
function update_tag(file, content, tagname, tagdate)
  local version = tagname:gsub("^v", "")
  return (content:gsub(
    "(\\ProvidesExpl%a+%s*{[%w]+}%s*){[%d%-]+}{[%w%.%-]+}",
    "%1{" .. tagdate .. "}{" .. version .. "}"))
end
