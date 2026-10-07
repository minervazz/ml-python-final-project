#!/bin/bash
# Execute one version's notebook, then export reveal.js slides + PDF (cells tagged hide_input show outputs only).
# Usage:  bash export.sh original_version
#         bash export.sh refined_version
#         RUN=0 bash export.sh refined_version     # export only, without re-running the notebook
set -e
cd "$(dirname "$0")/${1:?usage: bash export.sh original_version|refined_version}"
NB=$(basename "$(ls *.ipynb | head -n 1)" .ipynb)
HIDE="--TagRemovePreprocessor.remove_input_tags=hide_input"

if [ "${RUN:-1}" = 1 ]; then
  jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=3600 "$NB.ipynb"
fi
jupyter nbconvert --to slides "$NB.ipynb" $HIDE --SlidesExporter.reveal_scroll=True

# Fix nbconvert's scroll helper so long slides scroll fully inside the visible slide area
python3 - "$NB.slides.html" <<'PYFIX'
import sys
NEW = """        // Long slides: make them scroll inside the visible slide area (fixed height = slide height, re-centred)
        function setScrollingSlide() {
            var H = Reveal.getConfig().height;
            $('.reveal .slides section').filter(function() { return !$(this).children('section').length; })
              .each(function() {
                var s = $(this);
                s.css({'height': '', 'box-sizing': '', 'overflow-y': '', 'margin-top': ''});
                if (this.scrollHeight > H) { s.css({'height': H + 'px', 'box-sizing': 'border-box', 'overflow-y': 'auto'}); }
              });
            Reveal.layout();
        }
        Reveal.addEventListener('ready', setScrollingSlide);
        Reveal.addEventListener('slidechanged', setScrollingSlide);
        window.addEventListener('resize', setScrollingSlide);"""
for p in sys.argv[1:]:
    s = open(p).read()
    if 'box-sizing' in s and 'Long slides: make them scroll' in s:
        print('already fixed', p); continue
    a = s.index('        function setScrollingSlide() {')
    end_tok = "Reveal.addEventListener('slidechanged', setScrollingSlide);"
    b = s.index(end_tok) + len(end_tok)
    open(p, 'w').write(s[:a] + NEW + s[b:])
    print('fixed', p)
CSS = """<style id="slide-code-wrap">
.reveal .jp-InputArea pre, .reveal .highlight pre, .reveal .jp-OutputArea pre {
  white-space: pre-wrap !important; word-break: break-word; overflow-wrap: anywhere; overflow-x: hidden;
}
</style>
"""
for p in sys.argv[1:]:
    s = open(p).read()
    if 'id="slide-code-wrap"' not in s:
        i = s.rindex('</head>')
        open(p, 'w').write(s[:i] + CSS + s[i:])
        print('code wrap added', p)
PYFIX

# PDF: wrap long code/output lines and use slightly smaller margins
TMP=$(mktemp -d)
jupyter nbconvert --to latex "$NB.ipynb" $HIDE --output-dir "$TMP"
sed -i.bak 's/\\geometry{verbose,tmargin=1in,bmargin=1in,lmargin=1in,rmargin=1in}/\\geometry{verbose,tmargin=0.8in,bmargin=0.8in,lmargin=0.75in,rmargin=0.75in}\n    \\usepackage{fvextra}\\fvset{breaklines=true,breakanywhere=true,fontsize=\\small}\n    \\setcounter{secnumdepth}{0}/' "$TMP/$NB.tex"
(cd "$TMP" && xelatex -interaction=nonstopmode "$NB.tex" >/dev/null && xelatex -interaction=nonstopmode "$NB.tex" >/dev/null) || true
grep -i "missing character" "$TMP/$NB.log" || true
grep "^!" "$TMP/$NB.log" || true
cp "$TMP/$NB.pdf" .
rm -rf "${TMP:?}"
ls -la "$NB".*
