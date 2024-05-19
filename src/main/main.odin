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

CellGroup :: [9]^Cells

GenerateCellGroups :: proc(
	$cells: [81]Cell,
) -> (
	rows, cols, sqrs: [9]CellGroup,
	grps: [27]CellGroup,
) {
}

SudokuPuzzle :: struct {
	cells: [81]Cell,
	rows:  [9]CellGroup,
	cols:  [9]CellGroup,
	grps:  [9]CellGroup,
}
