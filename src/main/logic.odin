package SudokuSolver

import "../WaffleLib"
import "base:runtime"
import "core:fmt"

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

validate_sudoku_action :: proc(action: ^SudokuAction, ws: ^Workspace) -> (ok: bool) {
	return true
}

take_sudoku_action :: proc(
	action: ^SudokuAction,
	ws: ^Workspace,
) -> (
	err: runtime.Allocator_Error,
) {
	if validate_sudoku_action(action, ws) {
		WaffleLib.append_doubling(ws.puzzle.log, action^) or_return
		fmt.printfln("Action!!!")
		fmt.printfln("%v", action.logic)
		for change, i in action.changed do fmt.printfln("change %v: %v", i, change)
		for change in action.changed do if change != {} {
			ws.puzzle.data[change.row][change.col] = change.refValues[1]
		}
	}
	return nil
}

undo_sudoku_action :: proc(ws: ^Workspace) {
	if ws.puzzle.log == {} do return
	if len(ws.puzzle.log) == 0 do return

	action: SudokuAction = pop(ws.puzzle.log)

	for change in action.changed do if change != {} {
		ws.puzzle.data[change.row][change.col] = change.refValues[0]
	}
}

cell_add :: proc(cell, diff: Cell) -> Cell {
	switch d in diff {
	case CellPossibilities:
		switch c in cell {
		case CellPossibilities:
			return c + d
		case u16:
			s := CellPossibilities{int(c)} + d
			if card(s) > 1 {
				return s
			} else {
				for i in 1 ..= 9 do if i in s do return u16(i)
				return c
			}
		case:
			return c
		}
	case u16:
		switch c in cell {
		case CellPossibilities:
			s := CellPossibilities{int(d)} + c
			if card(s) > 1 {
				return s
			} else {
				for i in 1 ..= 9 do if i in s do return u16(i)
				return c
			}
		case u16:
			if c != d {
				return CellPossibilities{int(c), int(d)}
			} else {
				return c
			}
		case:
			return c
		}
	case:
		return cell
	}
}

cell_remove :: proc(cell, diff: Cell) -> Cell {
	#partial switch c in cell {
	case CellPossibilities:
		if card(c) == 1 do for i in 1 ..= 9 do if i in c do return u16(i)
		switch d in diff {
		case CellPossibilities:
			if c != d {
				return c - d
			} else {
				for i in 1 ..= 9 do if i in c do return u16(i)
			}
		case u16:
			return c - CellPossibilities{int(d)}
		case:
			return c
		}
	case:
		return c
	}
	return cell
}

toggle_possible :: proc(selection: ^Selection, pos: int, ws: ^Workspace) {
	if pos < 1 || pos > 9 do return

	action: SudokuAction

	if selection.group == .None {
		set_action_on_cell(coords_to_cell(selection.coords, ws), selection.coords, pos, &action)
	} else {
		group := sel_to_group(selection, ws)
		cellsContain: bool = false
		for cell in group^ do if c, ok := cell^.(CellPossibilities); ok {
			cellsContain = cellsContain || pos in c
		}

		if cellsContain {
			action.logic = .user_remove
		} else {
			action.logic = .user_add
		}

		for c, i in group^ {
			set_action_on_cell(c, sel_group_index_to_coords(selection, i), pos, &action)
		}
	}

	take_sudoku_action(&action, ws)
}

set_action_on_cell :: proc(cell: ^Cell, coords: CellCoords, pos: int, action: ^SudokuAction) {
	if action.logic == {} do switch c in cell^ {
	case CellPossibilities:
		if pos in c {
			if card(c) > 2 {
				action.logic = .user_remove
			} else {
				return
			}
		} else {
			action.logic = .user_add
		}
	case u16:
		if int(c) != pos {
			action.logic = .user_add
		} else {
			return
		}
	case:
		return
	}

	for &cref in action.changed {
		if cref == {} {
			cref.coords = coords
			cref.refValues[0] = cell^
			if action.logic == .user_add {
				cref.refValues[1] = cell_add(cell^, CellPossibilities{pos})
			} else {
				cref.refValues[1] = cell_remove(cell^, CellPossibilities{pos})
			}
			return
		}
	}
}

check_solved_cell :: proc(c: ^Cell) -> (isSolved: bool) {
	switch &cell in c^ {
	case u16:
		return cell >= 1 && cell <= 9
	case CellPossibilities:
		if card(cell) == 1 {
			for i in 1 ..= 9 {
				if i in cell {
					c^ = u16(i)
					return true
				}
			}
		}
		return false
	case:
		return false
	}
}
