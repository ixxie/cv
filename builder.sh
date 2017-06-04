 #!/usr/bin/env bash
set -e

Rscript ./in/code/run.R 

pandoc --latex-engine=xelatex -V geometry:margin=1.5cm --include-in-header=options.tex ./in/code/M.B.Shenhav-CV.md -o ./out/docs/M.B.Shenhav-CV.pdf