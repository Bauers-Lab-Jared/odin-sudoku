{
  stdenv,
  odin,
  go-task,
  qqwing,
  gdb,
}:
stdenv.mkDerivation rec {
  pname = "odin-sudoku";
  version = "0.1";
  src = ./src;

  nativeBuildInputs = [
    gdb
    go-task
    odin
    qqwing
  ];

  buildPhase = ''
    odin build ./main/ \
    -out:${pname}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin
  '';
}
