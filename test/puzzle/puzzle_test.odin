package puzzle

import src "../../src/main"
import "core:fmt"
import "core:testing"

@(test)
Test_Puzzle_Init :: proc(t: ^testing.T) {
	using src

	testPuzzle: SudokuPuzzle
	puzzle_init(&testPuzzle)
	i: u16
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			testing.expectf(
				t,
				testPuzzle.data[row][col] == CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9},
				`Freshly initialized puzzle expected to contain all possibilities.
        Cell[%v][%v]=%v`,
				row,
				col,
				testPuzzle.data[row][col],
			)
		}
	}
}


@(test)
Test_Workspace_Pointers :: proc(t: ^testing.T) {
	using src

	testPuzzle: SudokuPuzzle
	puzzle_init(&testPuzzle)
	ws: SudokuWorkspace
	set_workspace_Puzzle(&ws, &testPuzzle)
	i: u16
	for row in 0 ..= 8 {
		for col in 0 ..= 8 {
			testPuzzle.data[row][col] = i

			testing.expectf(
				t,
				ws.rows[row][col]^ == i,
				`puzzle.rows[%v][%v]=%v; Expected %v`,
				row,
				col,
				ws.rows[row][col]^,
				testPuzzle.data[row][col],
			)

			testing.expectf(
				t,
				ws.cols[col][row]^ == i,
				`puzzle.cols[%v][%v]=%v; Expected %v`,
				col,
				row,
				ws.cols[col][row]^,
				testPuzzle.data[row][col],
			)

			testing.expectf(
				t,
				ws.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)]^ == i,
				`puzzle.sqrs[%v][%v]=%v; Expected %v`,
				(col / 3) % 3 + 3 * (row / 3 % 3),
				col % 3 + 3 * (row % 3),
				ws.sqrs[(col / 3) % 3 + 3 * (row / 3 % 3)][col % 3 + 3 * (row % 3)]^,
				testPuzzle.data[row][col],
			)

			i += 1
		}
	}
}

@(test)
Test_Check_Solved_Cells :: proc(t: ^testing.T = {}) {
	using src
	testPuzzle: SudokuPuzzle
	puzzle_init(&testPuzzle)
	lut: [9][9]Cell

	testPuzzle.data[0] = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
	testPuzzle.data[1] = {
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
	testPuzzle.data[2] = {
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
	testPuzzle.data[3] = {
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
	testPuzzle.data[4] = {
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
	testPuzzle.data[5] = {
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
	testPuzzle.data[6] = {
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
	testPuzzle.data[7] = {
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
	testPuzzle.data[8] = {
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
			isSolved := check_solved_cell(&testPuzzle.data[x][y])
			expectlut := lut[x][y] != nil ? lut[x][y] : testPuzzle.data[x][y]
			testing.expect(
				t,
				testPuzzle.data[x][y] == expectlut,
				fmt.tprintf(
					"Expected [%v][%v] = %v; got %v",
					x,
					y,
					expectlut,
					testPuzzle.data[x][y],
				),
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
