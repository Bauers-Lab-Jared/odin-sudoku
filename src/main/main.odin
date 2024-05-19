package sudoku

import "core:fmt"

main :: proc() {
	puzzles, err := readSudokuFile("test-files/test-puzzles01")
}

CellValues :: bit_set[1 ..= 9]

Cell :: union {
	CellValues,
	u8,
}

SudokuPuzzle :: [81]Cell

CellGroup :: [9]^Cell

SudokuWorkspace :: struct {
	targetSudoku:     ^SudokuPuzzle,
	rows, cols, sqrs: [9]CellGroup,
	grps:             [27]CellGroup,
}

CreatRow :: proc(targ: ^SudokuPuzzle) -> (rows: [9]CellGroup) {
	for i in 0 ..< 9 {
		rows[i] = targ[(0 + (i * 9)):(8 + (i * 9))]
	}
}
