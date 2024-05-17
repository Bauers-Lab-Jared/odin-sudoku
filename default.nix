{
  stdenv,
  odin,
  clang,
  llvm_17,
}:
stdenv.mkDerivation (let
  name = "hello-world";
  src = ./src;
in {
  inherit name src;

  nativeBuildInputs = [
    odin
    clang
    llvm_17
  ];

  buildPhase = ''
    odin build ${src}/main -out:${name}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${name} $out/bin
  '';
})
