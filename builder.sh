 #!/usr/bin/env bash
set -e
 
pandoc --latex-engine=xelatex --include-in-header=options.tex ./fluxcraft.md -o ./fluxcraft.pdf