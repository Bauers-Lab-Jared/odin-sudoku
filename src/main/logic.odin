package SudokuSolver

import "WaffleLib"
import "base:runtime"
import "core:fmt"

sel_toggle_possible :: proc(selection: ^Selection, pos: int, ws: ^Workspace) {
	if pos < 1 || pos > 9 do return

	action: SudokuAction

	if selection.group == .None {
		set_action_on_cell(
			ws_get_cell_at_coords(ws, selection.coords),
			selection.coords,
			pos,
			&action,
		)
	} else {
		group := ws_select_group(ws, selection)
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
			set_action_on_cell(c, sel_get_coords_from_index(selection, i), pos, &action)
		}
	}

	ws_take_action(ws, &action)
}

set_action_on_cell :: proc(cell: ^Cell, coords: CellCoords, poss: int, action: ^SudokuAction) {
	if action.logic == {} do switch c in cell^ {
	case CellPossibilities:
		if poss in c {
			if card(c) > 2 {
				action.logic = .user_remove
			} else {
				return
			}
		} else {
			action.logic = .user_add
		}
	case u16:
		if int(c) != poss {
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
				cref.refValues[1] = cell_add(cell^, CellPossibilities{poss})
			} else {
				cref.refValues[1] = cell_remove(cell^, CellPossibilities{poss})
			}
			return
		}
	}
}
