{
  odin,
  coreutils,
  llvmPackages,
  libGL,
  xorg,
  lib,
  writeShellScript,
  patchelf,
}: let
  inherit (llvmPackages) stdenv;
in
  stdenv.mkDerivation rec {
    pname = "odin-sudoku";
    version = "0.1";
    src = ./src/main;

    LLVM_CONFIG = "${llvmPackages.llvm.dev}/bin/llvm-config";
    ODIN_ROOT = "${odin}/share";

    nativeBuildInputs = [
      odin
      llvmPackages.bintools
      llvmPackages.llvm
      llvmPackages.clang
      llvmPackages.lld
    ];

    dontConfigure = true;
    dontBuild = true;

    builder = let
      libPath = lib.makeLibraryPath [
        stdenv.cc.cc.lib
        libGL
        xorg.libX11
      ];
    in
      writeShellScript "builder.sh" ''
        export PATH="${coreutils}/bin:${odin}/bin"
        mkdir -p $out/bin
        odin build $src -out:$out/bin/$pname

        ${patchelf}/bin/patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${libPath}" \
          $out/bin/${pname}
      '';
  }
