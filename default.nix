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
stdenv.mkDerivation rec {
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
    ++ (odin-libs.getLibsByName odinLibNames);

  odinLibNames = [
    "waffle"
  ];

  buildInputs = [
    libX11
    libGL
    raylib
  ];

  buildPhase = ''
        runHook preBuild

        mkdir -p $out/bin

        odin build $src -out:$out/bin/$pname \
        ${odin-libs.mkBuildArgs odinLibNames} \
        -build-mode:exe \
    #    -vet \
    #    -disallow-do \
        -warnings-as-errors \
        -use-separate-modules \
        -define:RAYLIB_SYSTEM=true

        runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Resources
    cp -r $src/resources/ $out

    runHook postInstall
  '';
}
