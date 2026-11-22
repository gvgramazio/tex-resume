-- l3build configuration for the vitae class.
-- Run `l3build check` for regression tests, `l3build tag X.Y.Z` to bump versions.

module = "vitae"

-- Sources: class and themes live in src/ and are installed as-is (no .dtx/.ins).
sourcefiledir = "src"
sourcefiles   = {"*.cls", "*.sty"}
installfiles  = {"*.cls", "*.sty"}
tagfiles      = {"*.cls", "*.sty", "vitae-doc.tex"}

-- Tests: one .lvt per behaviour/edge case, checked on every supported engine.
testfiledir  = "testfiles"
checkengines = {"pdftex", "xetex", "luatex"}
stdengine    = "pdftex"
checkruns    = 1

-- Documentation: the user manual (docs/vitae-doc.tex, l3doc) and its samples,
-- small complete vitae documents that are compiled first and cropped to their
-- content, so the manual shows real code beside its real output.
docfiledir   = "docs"
typesetfiles = {"vitae-doc.tex"}
docfiles     = {"sample-*.tex"}

-- Compile each sample with pdfLaTeX in the typesetting directory (which holds
-- the class, the themes and the samples). The preloaded hooks wrap the body in
-- a 12 cm minipage inside preview's tight page, so the PDF is cropped exactly.
-- Samples named sample-page-* show page furniture (the footer): they set their
-- own small page, are not cropped, and run twice to resolve the page count.
local crop = "\\AddToHook{begindocument/before}"
  .. "{\\RequirePackage[active,tightpage]{preview}}"
  .. "\\AddToHook{begindocument/end}{\\begin{preview}\\begin{minipage}{12cm}}"
  .. "\\AddToHook{enddocument}{\\end{minipage}\\end{preview}}"
function typeset_demo_tasks()
  for _, p in ipairs(tree(typesetdir, "sample-*.tex")) do
    local name = jobname(p.src)
    local page = name:match("^sample%-page%-") ~= nil
    local cmd = "pdflatex -interaction=nonstopmode -halt-on-error \""
      .. (page and "" or crop) .. "\\input{" .. name .. "}\"" .. " > " .. os_null
    local errorlevel = run(typesetdir, cmd)
    if errorlevel == 0 and page then errorlevel = run(typesetdir, cmd) end
    if errorlevel ~= 0 then
      print("! Could not compile sample " .. name .. " (see " .. typesetdir
        .. "/" .. name .. ".log)")
      return errorlevel
    end
  end
  return 0
end

-- Packaging: README and LICENSE ship with the CTAN/release zip.
textfiles = {"README.md", "LICENSE", "CHANGELOG.md"}

-- Rewrite versions on `l3build tag`: `\ProvidesExpl...{name}{date}{version}`
-- in the sources and `\ProvidesFile{name}[date vversion ...]` in the manual.
function update_tag(file, content, tagname, tagdate)
  local version = tagname:gsub("^v", "")
  content = content:gsub(
    "(\\ProvidesExpl%a+%s*{[%w%.%-]+}%s*){[%d%-]+}{[%w%.%-]+}",
    "%1{" .. tagdate .. "}{" .. version .. "}")
  content = content:gsub(
    "(\\ProvidesFile%s*{[%w%.%-]+}%s*%[)[%d%-]+ v[%w%.%-]+",
    "%1" .. tagdate .. " v" .. version)
  return content
end
