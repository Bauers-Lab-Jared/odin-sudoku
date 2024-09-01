package SudokuSolver

import "base:runtime"

Cell :: union {
	u16,
	CellPossibilities,
}
CellPossibilities :: bit_set[1 ..= 9]
CellCoords :: struct {
	row, col: u8,
}
CellRef :: struct {
	using coords: CellCoords,
	refValues:    [2]Cell,
}

SudokuLogicType :: enum {
	group_conflict,
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
	changed, inRefTo: ^[]CellRef,
}

SudokuLog :: ^[]SudokuAction

CellData :: [9][9]Cell
CellGroup :: [9]^Cell
SudokuPuzzle :: struct {
	data: CellData,
	rows: [9]CellGroup,
	cols: [9]CellGroup,
	sqrs: [9]CellGroup,
	log:  ^SudokuLog,
}

CellEvalResult :: Cell
GroupEvalResult :: [9]CellEvalResult
GroupSetEvalResult :: [9]GroupEvalResult
AllGroupSetsEvalResult :: struct {
	rows: [9]GroupEvalResult,
	cols: [9]GroupEvalResult,
	sqrs: [9]GroupEvalResult,
}

PuzzleEvalResult :: union {
	GroupSetEvalResult,
	AllGroupSetsEvalResult,
}

puzzle_buffer_make :: proc(
	allocator := context.allocator,
) -> (
	res: [dynamic]SudokuPuzzle,
	err: runtime.Allocator_Error,
) {
	return make([dynamic]SudokuPuzzle, 0, 16)
}

puzzle_buffer_append :: proc(
	puzzleBuffer: ^[dynamic]SudokuPuzzle,
	puzzle: ^SudokuPuzzle,
	allocator := context.allocator,
) -> runtime.Allocator_Error {
	if len(puzzleBuffer) == cap(puzzleBuffer) {
		reserve(puzzleBuffer, len(puzzleBuffer) * 2) or_return
	}
	append(puzzleBuffer, puzzle^) or_return
	return nil
}

puzzle_init :: proc(puzzle: ^SudokuPuzzle) {
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			puzzle.data[row][col] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
			ptr := &puzzle.data[row][col]

			puzzle.rows[row][col] = ptr
			puzzle.cols[col][row] = ptr
			puzzle.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)] = ptr
		}
	}
	return
}

CellEval :: proc(c: ^Cell) -> CellEvalResult
GroupEval :: proc(group: ^CellGroup) -> GroupEvalResult

map_over_group :: proc(group: ^CellGroup, f: CellEval) -> GroupEvalResult {
	result: GroupEvalResult
	for cell, i in group {
		result[i] = f(cell)
	}
	return result
}

map_over_groupSet_by_cell :: proc(groupSet: ^[9]CellGroup, f: CellEval) -> [9]GroupEvalResult {
	result: [9]GroupEvalResult
	for &group, i in groupSet {
		result[i] = map_over_group(&group, f)
	}
	return result
}

map_over_groupSet_by_group :: proc(groupSet: ^[9]CellGroup, f: GroupEval) -> [9]GroupEvalResult {
	result: [9]GroupEvalResult
	for &group, i in groupSet {
		result[i] = f(&group)
	}
	return result
}

map_over_groupSet :: proc {
	map_over_groupSet_by_cell,
	map_over_groupSet_by_group,
}

map_over_puzzle_by_cell :: proc(puzzle: ^SudokuPuzzle, f: CellEval) -> PuzzleEvalResult {
	result: GroupSetEvalResult
	result = map_over_groupSet(&puzzle.rows, f)
	return result
}

map_over_puzzle_by_group :: proc(puzzle: ^SudokuPuzzle, f: GroupEval) -> PuzzleEvalResult {
	result: AllGroupSetsEvalResult
	result.rows = map_over_groupSet(&puzzle.rows, f)
	result.cols = map_over_groupSet(&puzzle.cols, f)
	result.sqrs = map_over_groupSet(&puzzle.sqrs, f)
	return result
}

map_over_puzzle :: proc {
	map_over_puzzle_by_cell,
	map_over_puzzle_by_group,
}

check_solved_cells :: proc(puzzle: ^SudokuPuzzle) -> (result: GroupSetEvalResult) {
	result = map_over_puzzle(puzzle, proc(c: ^Cell) -> CellEvalResult {
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
	}).(GroupSetEvalResult)
	return result
}
