{
  stdenv,
  odin,
  go-task,
  qqwing,
  gdb,
  libGL,
  xorg,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "odin-sudoku";
  version = "0.1";
  src = ./src;

  nativeBuildInputs = [
    gdb
    go-task
    qqwing
    autoPatchelfHook
  ];

  buildInputs = [
    libGL
    xorg.libX11
    odin
  ];

  buildPhase = ''
    runHook preBuild

    odin build ./main/ \
    -out:${pname} \
    -extra-linker-flags:"-l:${odin}/share/vendor/raylib/linux/libraylib.a"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${pname} $out/bin

    runHook postInstall
  '';
}
