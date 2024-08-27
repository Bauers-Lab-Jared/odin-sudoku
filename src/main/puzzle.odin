package SudokuSolver

Cell :: union {
	u16,
	CellPossibilities,
}
CellPossibilities :: bit_set[1 ..= 9]

CellData :: [9][9]Cell
CellGroup :: [9]^Cell
SudokuPuzzle :: struct {
	data: CellData,
	rows: [9]CellGroup,
	cols: [9]CellGroup,
	sqrs: [9]CellGroup,
}

CellEvalResult :: Cell
GroupEvalResult :: [9]CellEvalResult
GroupsEvalResult :: [9]GroupEvalResult
AllGroupsEvalResult :: struct {
	rows: [9]GroupEvalResult,
	cols: [9]GroupEvalResult,
	sqrs: [9]GroupEvalResult,
}
PuzzleEvalResult :: union {
	GroupsEvalResult,
	AllGroupsEvalResult,
}

Puzzle_Init :: proc(puzzle: ^SudokuPuzzle) {
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			puzzle.data[row][col] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}

			puzzle.rows[row][col] = &puzzle.data[row][col]
			puzzle.cols[col][row] = &puzzle.data[row][col]
			puzzle.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)] =
			&puzzle.data[row][col]
		}
	}
	return
}

CellEval :: proc(c: ^Cell) -> CellEvalResult
GroupEval :: proc(group: ^CellGroup) -> GroupEvalResult

Map_Over_Group :: proc(group: ^CellGroup, f: CellEval) -> GroupEvalResult {
	result: GroupEvalResult
	for cell, i in group {
		result[i] = f(cell)
	}
	return result
}

Map_Over_Groups_By_Cell :: proc(groups: ^[9]CellGroup, f: CellEval) -> [9]GroupEvalResult {
	result: [9]GroupEvalResult
	for &group, i in groups {
		result[i] = Map_Over_Group(&group, f)
	}
	return result
}

Map_Over_Groups_By_Group :: proc(groups: ^[9]CellGroup, f: GroupEval) -> [9]GroupEvalResult {
	result: [9]GroupEvalResult
	for &group, i in groups {
		result[i] = f(&group)
	}
	return result
}

Map_Over_Groups :: proc {
	Map_Over_Groups_By_Cell,
	Map_Over_Groups_By_Group,
}

Map_Over_Puzzle_By_Cell :: proc(puzzle: ^SudokuPuzzle, f: CellEval) -> PuzzleEvalResult {
	result: GroupsEvalResult
	result = Map_Over_Groups(&puzzle.rows, f)
	return result
}

Map_Over_Puzzle_By_Group :: proc(puzzle: ^SudokuPuzzle, f: GroupEval) -> PuzzleEvalResult {
	result: AllGroupsEvalResult
	result.rows = Map_Over_Groups(&puzzle.rows, f)
	result.cols = Map_Over_Groups(&puzzle.cols, f)
	result.sqrs = Map_Over_Groups(&puzzle.sqrs, f)
	return result
}

Map_Over_Puzzle :: proc {
	Map_Over_Puzzle_By_Cell,
	Map_Over_Puzzle_By_Group,
}

Check_Solved_Cells :: proc(puzzle: ^SudokuPuzzle) -> (result: GroupsEvalResult) {
	result = Map_Over_Puzzle(puzzle, proc(c: ^Cell) -> CellEvalResult {
		cellResult: CellEvalResult
		cell, isSet := c^.(CellPossibilities)
		if isSet && card(cell) == 1 {
			for i in 1 ..= 9 {
				if i in cell {
					cellResult = u16(i)
				}
			}
		}
		return cellResult
	}).(GroupsEvalResult)
	return result
}
