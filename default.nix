{
  stdenv,
  odin,
  go-task,
  qqwing,
  gdb,
  libGL,
  libX11,
  raylib,
  odin-libs,
}:
stdenv.mkDerivation {
  pname = "odin-sudoku";
  version = "0.1";
  src = ./src/main;

  nativeBuildInputs =
    [
      gdb
      go-task
      odin
      qqwing
    ]
    ++ odin-libs.pkgs;

  # Inputs to be available at runtime
  buildInputs = [
    libX11
    libGL
    raylib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    ${odin-libs.odinCMD "build"}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/resources
    cp -r $src/resources/ $out

    runHook postInstall
  '';
}
