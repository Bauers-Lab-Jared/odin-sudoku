[
  {
    pname = "odin-sudoku";
    version = "0.1";
    src = ./src/main;
    libs.import = ["waffle"];
    raylib.enable = true;
    nativeBuildInputs = ["qqwing"];
  }
]
