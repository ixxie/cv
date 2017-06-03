 #!/usr/bin/env bash
set -e

Rscript ./R/run.R 

pandoc --latex-engine=xelatex -V geometry:margin=2cm --include-in-header=options.tex ./M.B.Shenhav-CV.md -o ./M.B.Shenhav-CV.pdf