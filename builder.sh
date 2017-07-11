 #!/usr/bin/env bash
set -e

Rscript ./code/run.R 

pandoc -fmarkdown-implicit_figures --latex-engine=xelatex -V geometry:margin=1.8cm -V papersize:a4 --include-in-header=./code/options.tex -o ./docs/M.B.Shenhav-CV.pdf ./code/M.B.Shenhav-CV.md 

#pandoc -t json ./code/M.B.Shenhav-CV.md  | python "./code/tab-img.py" | pandoc -f json -o ./docs/M.B.Shenhav-CV.pdf