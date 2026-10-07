#!/bin/bash
# Rebuild everything: run the notebook (writes figures/ and submissions/), then compile the report and the slides.
# Usage:  bash build.sh            # full rebuild (the notebook takes about 5-10 minutes)
#         RUN=0 bash build.sh      # only recompile the LaTeX files
set -e
cd "$(dirname "$0")"
if [ "${RUN:-1}" = 1 ]; then
  jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=3600 notebook/zindi_engagement.ipynb
fi
for f in report/report slides/slides; do
  (cd "$(dirname $f)" && pdflatex -interaction=nonstopmode "$(basename $f).tex" >/dev/null \
                      && pdflatex -interaction=nonstopmode "$(basename $f).tex" >/dev/null \
                      && rm -f *.aux *.log *.out *.nav *.snm *.toc *.vrb)
  echo "built $f.pdf"
done
