let

  pkgs = import <nixpkgs> {};

in

  pkgs.runCommand "test" 
  {

    buildInputs = 
    [
      pkgs.pandoc
      pkgs.texlive.combined.scheme-small
    ];

    src = ./.;

  } 
  ''
    mkdir -p $out
    pandoc --latex-engine=xelatex --include-in-header=$src/options.tex $src/fluxcraft.md -o $out/fluxcraft.pdf
    echo ls $src/fonts/* > $out/test
  ''