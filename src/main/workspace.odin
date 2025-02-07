package SudokuSolver

import "base:runtime"
import "core:fmt"
import waffle "waffle:lib"

Puzzle :: [9][9]Cell

puzzle_init :: proc(puzzle: ^Puzzle) -> ^Puzzle {
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			puzzle[row][col] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
		}
	}
	return puzzle
}

SudokuLogicType :: enum {
	user_add,
	user_remove,
	obvious_single,
	last_possible,
	obvious_pair,
	obvious_trio,
	hidden_single,
	hidden_pair,
	hidden_trio,
	intersect_pin, //pointing pair/trio
	x_wing,
	y_wing,
	swordfish,
	binary_guess,
}
SudokuAction :: struct {
	logic:            SudokuLogicType,
	changed, inRefTo: [9]CellRef,
}
SudokuLog :: [dynamic]SudokuAction

Workspace :: struct {
	puzzle: ^Puzzle,
	rows:   [9]CellGroup,
	cols:   [9]CellGroup,
	sqrs:   [9]CellGroup,
	log:    ^SudokuLog,
}

ws_validate_action :: proc(ws: ^Workspace, action: ^SudokuAction) -> (ok: bool) {
	return true
}

ws_take_action :: proc(ws: ^Workspace, action: ^SudokuAction) -> (err: runtime.Allocator_Error) {
	if ws_validate_action(ws, action) {
		waffle.append_doubling(ws.log, action^) or_return
		fmt.printfln("Action!!!")
		fmt.printfln("%v", action.logic)
		for change, i in action.changed do fmt.printfln("change %v: %v", i, change)
		for change in action.changed do if change != {} {
			ws.puzzle[change.row][change.col] = change.refValues[1]
		}
	}
	return nil
}

ws_undo_action :: proc(ws: ^Workspace) {
	if ws.log == {} do return
	if len(ws.log) == 0 do return
	action: SudokuAction = pop(ws.log)
	for change in action.changed do if change != {} {
		ws.puzzle[change.row][change.col] = change.refValues[0]
	}
}

ws_get_cell_at_coords :: proc(ws: ^Workspace, coords: CellCoords) -> ^Cell {
	return (ws.rows[coords.row])[coords.col]
}

ws_select_group :: proc(ws: ^Workspace, selection: ^Selection) -> (grp: ^CellGroup) {
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

ws_set_puzzle :: proc(ws: ^Workspace, puzzle: ^Puzzle) -> (err: runtime.Allocator_Error) {
	if ws.log == {} {
		ws.log = new(SudokuLog) or_return
		reserve(ws.log, 32)
	}
	ws.puzzle = puzzle
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			ptr := &puzzle[row][col]
			ws.rows[row][col] = ptr
			ws.cols[col][row] = ptr
			ws.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)] = ptr
		}
	}
	return nil
}
