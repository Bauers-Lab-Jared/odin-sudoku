{
  stdenv,
  odin,
  clang,
  llvm_17,
  go-task,
  qqwing,
}:
stdenv.mkDerivation (let
  name = "hello-world";
  src = ./src;
in {
  inherit name src;

  nativeBuildInputs = [
    go-task
    odin
    clang
    llvm_17
    qqwing
  ];

  buildPhase = ''
    odin build ${src}/main -out:${name}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${name} $out/bin
  '';
})
