{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  name = "hello-world";
  src = ./test;

  buildInputs = with pkgs; [
    ncurses
  ];

  buildPhase = ''
    g++ hello-world.cpp -o hello-world -l ncurses
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp hello-world $out/bin
  '';
}
