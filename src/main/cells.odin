package SudokuSolver

CellPossibilities :: distinct bit_set[1 ..= 9]
Cell :: union {
	u16,
	CellPossibilities,
}
CellCoords :: struct {
	row, col: u8,
}
CellRef :: struct {
	using coords: CellCoords,
	refValues:    [2]Cell,
}

CellGroup :: [9]^Cell

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

cell_check_solved :: proc(c: ^Cell) -> (isSolved: bool) {
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
