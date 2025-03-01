package SudokuSolver

import "core:fmt"
import "core:testing"

@(test)
Test_Puzzle_Init :: proc(t: ^testing.T) {

	testPuzzle: Puzzle
	puzzle_init(&testPuzzle)
	i: u16
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			testing.expectf(
				t,
				testPuzzle[row][col] == CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9},
				`Freshly initialized puzzle expected to contain all possibilities.
        Cell[%v][%v]=%v`,
				row,
				col,
				testPuzzle[row][col],
			)
		}
	}
}


@(test)
Test_Workspace_Pointers :: proc(t: ^testing.T) {

	testPuzzle: Puzzle
	puzzle_init(&testPuzzle)
	ws: Workspace
	ws_set_puzzle(&ws, &testPuzzle)
	i: u16
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			testPuzzle[row][col] = i

			testing.expectf(
				t,
				ws.rows[row][col]^ == i,
				`puzzle.rows[%v][%v]=%v; Expected %v`,
				row,
				col,
				ws.rows[row][col]^,
				testPuzzle[row][col],
			)

			testing.expectf(
				t,
				ws.cols[col][row]^ == i,
				`puzzle.cols[%v][%v]=%v; Expected %v`,
				col,
				row,
				ws.cols[col][row]^,
				testPuzzle[row][col],
			)

			testing.expectf(
				t,
				ws.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)]^ == i,
				`puzzle.sqrs[%v][%v]=%v; Expected %v`,
				(col / 3) % 3 + 3 * (row / 3 % 3),
				col % 3 + 3 * (row % 3),
				ws.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)]^,
				testPuzzle[row][col],
			)

			i += 1
		}
	}
}

@(test)
Test_Check_Solved_Cells :: proc(t: ^testing.T = {}) {
	testPuzzle: Puzzle
	puzzle_init(&testPuzzle)
	lut: [9][9]Cell

	testPuzzle[0] = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
	testPuzzle[1] = {
		CellPossibilities{1},
		CellPossibilities{2},
		CellPossibilities{3},
		CellPossibilities{4},
		CellPossibilities{5},
		CellPossibilities{6},
		CellPossibilities{7},
		CellPossibilities{8},
		CellPossibilities{9},
	}
	testPuzzle[2] = {
		CellPossibilities{1, 2},
		CellPossibilities{2, 3},
		CellPossibilities{3, 4},
		CellPossibilities{4, 5},
		CellPossibilities{5, 6},
		CellPossibilities{6, 7},
		CellPossibilities{7, 8},
		CellPossibilities{8, 9},
		CellPossibilities{9},
	}
	testPuzzle[3] = {
		CellPossibilities{1, 2, 3},
		CellPossibilities{2, 3, 4},
		CellPossibilities{3, 4, 5},
		CellPossibilities{4, 5, 6},
		CellPossibilities{5, 6, 7},
		CellPossibilities{6, 7, 8},
		CellPossibilities{7, 8, 9},
		CellPossibilities{8, 9},
		CellPossibilities{9},
	}
	testPuzzle[4] = {
		CellPossibilities{1, 2, 3, 4},
		CellPossibilities{2, 3, 4, 5},
		CellPossibilities{3, 4, 5, 6},
		CellPossibilities{4, 5, 6, 7},
		CellPossibilities{5, 6, 7, 8},
		CellPossibilities{6, 7, 8, 9},
		CellPossibilities{7, 8, 9},
		CellPossibilities{8, 9},
		CellPossibilities{9},
	}
	testPuzzle[5] = {
		CellPossibilities{1, 2, 3, 4, 5},
		CellPossibilities{2, 3, 4, 5, 6},
		CellPossibilities{3, 4, 5, 6, 7},
		CellPossibilities{4, 5, 6, 7, 8},
		CellPossibilities{5, 6, 7, 8, 9},
		CellPossibilities{6, 7, 8, 9},
		CellPossibilities{7, 8, 9},
		CellPossibilities{8, 9},
		CellPossibilities{9},
	}
	testPuzzle[6] = {
		CellPossibilities{1, 2, 3, 4, 5, 6},
		CellPossibilities{2, 3, 4, 5, 6, 7},
		CellPossibilities{3, 4, 5, 6, 7, 8},
		CellPossibilities{4, 5, 6, 7, 8, 9},
		CellPossibilities{5, 6, 7, 8, 9},
		CellPossibilities{6, 7, 8, 9},
		CellPossibilities{7, 8, 9},
		CellPossibilities{8, 9},
		CellPossibilities{9},
	}
	testPuzzle[7] = {
		CellPossibilities{1, 2, 3, 4, 5, 6, 7},
		CellPossibilities{2, 3, 4, 5, 6, 7, 8},
		CellPossibilities{3, 4, 5, 6, 7, 8, 9},
		CellPossibilities{4, 5, 6, 7, 8, 9},
		CellPossibilities{5, 6, 7, 8, 9},
		CellPossibilities{6, 7, 8, 9},
		CellPossibilities{7, 8, 9},
		CellPossibilities{8, 9},
		CellPossibilities{9},
	}
	testPuzzle[8] = {
		CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8},
		CellPossibilities{2, 3, 4, 5, 6, 7, 8, 9},
		CellPossibilities{3, 4, 5, 6, 7, 8, 9},
		CellPossibilities{4, 5, 6, 7, 8, 9},
		CellPossibilities{5, 6, 7, 8, 9},
		CellPossibilities{6, 7, 8, 9},
		CellPossibilities{7, 8, 9},
		CellPossibilities{8, 9},
		CellPossibilities{9},
	}

	lut[0] = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
	lut[1] = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	lut[2] = {nil, nil, nil, nil, nil, nil, nil, nil, 9}
	lut[3] = {nil, nil, nil, nil, nil, nil, nil, nil, 9}
	lut[4] = {nil, nil, nil, nil, nil, nil, nil, nil, 9}
	lut[5] = {nil, nil, nil, nil, nil, nil, nil, nil, 9}
	lut[6] = {nil, nil, nil, nil, nil, nil, nil, nil, 9}
	lut[7] = {nil, nil, nil, nil, nil, nil, nil, nil, 9}
	lut[8] = {nil, nil, nil, nil, nil, nil, nil, nil, 9}

	for x in 0 ..< 9 {
		for y in 0 ..< 9 {
			isSolved := cell_check_solved(&testPuzzle[x][y])
			expectlut := lut[x][y] != nil ? lut[x][y] : testPuzzle[x][y]
			testing.expect(
				t,
				testPuzzle[x][y] == expectlut,
				fmt.tprintf("Expected [%v][%v] = %v; got %v", x, y, expectlut, testPuzzle[x][y]),
			)

			expect: bool
			switch {
			case x == 1:
				expect = true
			case x >= 2 && y == 8:
				expect = true
			case:
				expect = false
			}

			testing.expect(
				t,
				isSolved == expect,
				fmt.tprintf("Expected [%v][%v] isSolved = %v; got %v", x, y, expect, isSolved),
			)
		}
	}
}
