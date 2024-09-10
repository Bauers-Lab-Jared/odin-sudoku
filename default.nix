{
  clangStdenv,
  odin,
  go-task,
  qqwing,
  gdb,
  libGL,
  xorg,
}:
clangStdenv.mkDerivation rec {
  pname = "odin-sudoku";
  version = "0.1";
  src = ./src;

  nativeBuildInputs = [
    go-task
    qqwing
    odin
    gdb
  ];

  buildInputs = [
    libGL
    xorg.libX11
  ];

  buildPhase = ''
    runHook preBuild

    ${odin}/bin/odin build ./main/ \
    -out:${pname} \

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${pname} $out/bin

    runHook postInstall
  '';
}
