 #!/usr/bin/env bash
set -e

Rscript ./in/code/run.R 

pandoc -fmarkdown-implicit_figures --latex-engine=xelatex -V geometry:margin=1.8cm --include-in-header=./in/code/options.tex -o ./out/docs/M.B.Shenhav-CV.pdf ./in/code/M.B.Shenhav-CV.md 

#pandoc -t json ./in/code/M.B.Shenhav-CV.md  | python "./in/code/tab-img.py" | pandoc -f json -o ./out/docs/M.B.Shenhav-CV.pdf