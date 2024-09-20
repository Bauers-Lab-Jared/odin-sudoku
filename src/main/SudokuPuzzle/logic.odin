package SudokuPuzzle

import "base:runtime"

SudokuLogicType :: enum {
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

toggle_possible :: proc {
	toggle_possible_on_sel,
	toggle_possible_on_group,
	toggle_possible_on_cell,
}

toggle_possible_on_sel :: proc(selection: ^Selection, pos: CellPossibilities, ws: ^Workspace) {
	targetCells: ^CellGroup
	targetCell: ^Cell

	switch selection.group {
	case .Row:
		targetCells = &ws.rows[selection.coords.row]
	case .Col:
		targetCells = &ws.cols[selection.coords.col]
	case .Sqr:
		targetCells = &ws.sqrs[selection.coords.col / 3 + (selection.coords.row / 3) * 3]
	case .None:
		targetCell = (ws.rows[selection.coords.row])[selection.coords.col]
	}
	if targetCells != {} {
		toggle_possible(targetCells, pos)
	} else if targetCell != {} {
		toggle_possible(targetCell, pos)
	}
}

toggle_possible_on_group :: proc(group: ^CellGroup, pos: CellPossibilities) {
	noCellsContain: CellPossibilities = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	allCellsContain := noCellsContain
	for cell in group^ do if c, ok := cell^.(CellPossibilities); ok {
		noCellsContain = noCellsContain - c
		allCellsContain = allCellsContain & c
	}
	togglePos := pos | (allCellsContain + noCellsContain)
	//    in | mask -> toggle
	// mix - 1 0 -> 1
	//       0 0 -> 0
	// none - 0 1 -> 1
	// all - 1 1 -> 1

	for cell in group^ {
		toggle_possible(cell, togglePos)
	}
}

toggle_possible_on_cell :: proc(cell: ^Cell, pos: CellPossibilities) {
	if card(pos) == 0 do return

	switch &c in cell^ {
	case CellPossibilities:
		c = c ~ pos
	case u16:
		switch card(pos) {
		case 0:
		case 1:
			if int(c) not_in pos {
				cell^ = CellPossibilities{int(c)} + pos
			}
		case 2 ..= 9:
			cell^ = CellPossibilities{int(c)} ~ pos
		case:
		}
	case:
	}

	if c, ok := cell^.(CellPossibilities); ok do switch card(c) {
	case 0:
		for i := 9; i >= 1; i -= 1 do if i in pos do cell^ = u16(i)
	case 1:
		for i := 9; i >= 1; i -= 1 do if i in c do cell^ = u16(i)
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
