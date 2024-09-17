package SudokuPuzzle

import "../WaffleLib"
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

CellData :: [9][9]Cell
CellGroup :: [9]^Cell
Puzzle :: struct {
	data: CellData,
	log:  ^SudokuLog,
}

SudokuWorkspace :: struct {
	puzzle:  ^Puzzle,
	rows:    [9]CellGroup,
	cols:    [9]CellGroup,
	sqrs:    [9]CellGroup,
	scratch: ^SudokuLog,
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

puzzle_init :: proc(puzzle: ^Puzzle) -> ^Puzzle {
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			puzzle.data[row][col] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
		}
	}
	return puzzle
}

set_workspace_Puzzle :: proc(workspace: ^SudokuWorkspace, puzzle: ^Puzzle) {
	workspace.puzzle = puzzle

	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			ptr := &puzzle.data[row][col]

			workspace.rows[row][col] = ptr
			workspace.cols[col][row] = ptr
			workspace.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)] = ptr
		}
	}
	return
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
