{
  stdenv,
  odin,
  go-task,
  qqwing,
  gdb,
  coreutils,
  libGL,
  xorg,
  lib,
  writeShellScript,
  patchelf,
}:
stdenv.mkDerivation rec {
  pname = "odin-sudoku";
  version = "0.1";
  src = ./src/main;

  nativeBuildInputs = [
    gdb
    go-task
    odin
    qqwing
  ];

  buildInputs = [
    libGL
    xorg.libX11
  ];

  builder = let
    libPath = lib.makeLibraryPath buildInputs;
  in
    writeShellScript "builder.sh" ''
      export PATH="${coreutils}/bin:${odin}/bin"
      mkdir -p $out/bin
      odin build $src -out:$out/bin/$pname

      mkdir -p $out/Resources
      cp -r $src/Resources/ $out

      ${patchelf}/bin/patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/bin/${pname}
    '';
}
