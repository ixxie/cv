 #!/usr/bin/env bash
set -e

Rscript ./in/R/run.R 

pandoc --latex-engine=xelatex -V geometry:margin=1.5cm --include-in-header=options.tex ./in/M.B.Shenhav-CV.md -o ./out/M.B.Shenhav-CV.pdf