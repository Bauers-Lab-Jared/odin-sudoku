{
  stdenv,
  odin,
  clang,
  llvm_17,
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
    clang
    llvm_17
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
