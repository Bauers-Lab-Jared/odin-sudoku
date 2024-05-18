package sudoku

import "core:fmt"

main :: proc() {
	puzzles, err := readSudokuFile("test-files/test-puzzles01")

	for p in puzzles do fmt.println(p)
}

SudokuPuzzle :: struct {
	cells: [81]u8,
}
