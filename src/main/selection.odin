package SudokuSolver

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

sel_get_coords_from_index :: proc(
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
