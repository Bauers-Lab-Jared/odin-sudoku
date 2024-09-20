package SudokuPuzzle

import "base:runtime"

Cell :: union {
	u16,
	CellPossibilities,
}
CellPossibilities :: distinct bit_set[1 ..= 9]
CellCoords :: struct {
	row, col: u8,
}
CellRef :: struct {
	using coords: CellCoords,
	refValues:    [2]Cell,
}

CellData :: [9][9]Cell
CellGroup :: [9]^Cell
Puzzle :: struct {
	data: CellData,
	log:  ^SudokuLog,
}

SelectionGroup :: enum {
	None,
	Row,
	Col,
	Sqr,
}

Selection :: struct {
	coords: CellCoords,
	group:  SelectionGroup,
}

Workspace :: struct {
	puzzle:  ^Puzzle,
	rows:    [9]CellGroup,
	cols:    [9]CellGroup,
	sqrs:    [9]CellGroup,
	scratch: ^SudokuLog,
}

puzzle_init :: proc(puzzle: ^Puzzle) -> ^Puzzle {
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			puzzle.data[row][col] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
		}
	}
	return puzzle
}

set_workspace_Puzzle :: proc(workspace: ^Workspace, puzzle: ^Puzzle) {
	workspace.puzzle = puzzle

	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			ptr := &puzzle.data[row][col]

			workspace.rows[row][col] = ptr
			workspace.cols[col][row] = ptr
			workspace.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)] = ptr
		}
	}
	return
}
