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
    pandoc --latex-engine=xelatex $src/fluxcraft.md -o $out/fluxcraft.pdf
    echo ls $src/fonts/* > $out/test
  ''