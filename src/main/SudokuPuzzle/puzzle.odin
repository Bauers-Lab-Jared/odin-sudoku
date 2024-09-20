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

sel_to_group :: proc(selection: ^Selection, ws: ^Workspace) -> (grp: ^CellGroup) {
	switch selection.group {
	case .Row:
		grp = &ws.rows[selection.coords.row]
	case .Col:
		grp = &ws.cols[selection.coords.col]
	case .Sqr:
		grp = &ws.sqrs[selection.coords.col / 3 + (selection.coords.row / 3) * 3]
	case .None:
		grp = &ws.rows[selection.coords.row]
	}
	return
}

sel_group_index_to_coords :: proc(
	selection: ^Selection,
	#any_int index: u8,
) -> (
	coords: CellCoords,
) {
	switch selection.group {
	case .Row:
		coords = {
			row = selection.coords.row,
			col = index,
		}
	case .Col:
		coords = {
			row = index,
			col = selection.coords.col,
		}
	case .Sqr:
		coords = {
			row = selection.coords.row / 3 + index / 3,
			col = selection.coords.col / 3 + index % 3,
		}
	case .None:
		coords = {
			row = 0,
			col = 0,
		}
	}
	return
}

coords_to_cell :: proc(coords: CellCoords, ws: ^Workspace) -> ^Cell {
	return (ws.rows[coords.row])[coords.col]
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

set_workspace_Puzzle :: proc(
	workspace: ^Workspace,
	puzzle: ^Puzzle,
) -> (
	err: runtime.Allocator_Error,
) {
	if puzzle.log == {} {
		puzzle.log = new(SudokuLog) or_return
		reserve(puzzle.log, 32)
	}

	workspace.puzzle = puzzle

	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			ptr := &puzzle.data[row][col]

			workspace.rows[row][col] = ptr
			workspace.cols[col][row] = ptr
			workspace.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)] = ptr
		}
	}
	return nil
}
