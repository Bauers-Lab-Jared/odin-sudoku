package SudokuSolver

import "base:runtime"
import "core:fmt"
import waffle "waffle:lib"

sel_set_possible :: proc(
	selection: ^Selection,
	#any_int poss: int,
	ws: ^Workspace,
	set: bool = false,
) {
	if poss < 1 || poss > 9 do return
	action: SudokuAction = {.user_add if set else .user_remove, {}, {}}
	if selection.group == .None {
		set_action_on_cell(
			ws_get_cell_at_coords(ws, selection.coords),
			selection.coords,
			poss,
			&action,
		)
	} else {
		group := ws_select_group(ws, selection)
		set_action_on_group(group, poss, &action, selection)
	}
	ws_take_action(ws, &action)
}

sel_toggle_possible :: proc(selection: ^Selection, #any_int poss: int, ws: ^Workspace) {
	if poss < 1 || poss > 9 do return

	action: SudokuAction

	if selection.group == .None {
		set_action_on_cell(
			ws_get_cell_at_coords(ws, selection.coords),
			selection.coords,
			poss,
			&action,
		)
	} else {
		group := ws_select_group(ws, selection)
		action.logic = .user_add
		for cell in group^ do if c, ok := cell^.(CellPossibilities); ok {
			if poss in c {
				action.logic = .user_remove
				break
			}
		}
		set_action_on_group(group, poss, &action, selection)
	}
	ws_take_action(ws, &action)
}

set_action_on_group :: proc(
	group: ^CellGroup,
	#any_int poss: int,
	action: ^SudokuAction,
	selection: ^Selection,
) {
	for c, i in group^ {
		set_action_on_cell(c, sel_get_coords_from_index(selection, i), poss, action)
	}
}

set_action_on_cell :: proc(
	cell: ^Cell,
	coords: CellCoords,
	#any_int poss: int,
	action: ^SudokuAction,
) {
	if action.logic == {} do switch c in cell^ {
	case CellPossibilities:
		if poss in c {
			if card(c) > 1 {
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
