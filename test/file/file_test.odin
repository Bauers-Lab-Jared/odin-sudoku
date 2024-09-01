package file

import src "../../src/main"
import "core:fmt"
import "core:strings"
import "core:testing"

@(test)
test_read_sudoku_file :: proc(t: ^testing.T) {
	using src
	testFile :: "test-files/test-puzzles01"
	dummyFile := `
...6928......74..1..5.8.......4.1...6...5.2.....7...6......6..52.4...61.59.....4.
6...7..8.2.43.8........17....9..28.3.4.7..9....8..617.....4..9........3..1..2....
...2..9.7..1.....26.4....51...79...8482.1.7.9.97.2.1...5.......1........2.9...5.6
6....4.2.....3.7..5........3...92.6..1.....54...71.......3.9645..7.5..3.........1
.61......4.5..93..92.............1....6..3...59..6.438...48..6.....1.845.3.......
..5..3.2.3.2...9.819.6....7...2.9.......8.....7.5....1.2...5..9...7.....93...2.1.
..5..9........543..43......5......1367.1....4......69..9..6.1....2..7...3..9.2..7
...9...7..8.3.45.13.75.....9...5.4...6.......4.......6.1.86...58.3....9.........7
9......4585.6...1..47....3...35...8..9.8..5..7...46........89......75....1.9.....
.4......92.6..3.4.....5..2.83..6.....69..2.....2.7...8..8.2.4.63....45...2.9.....
3....2..62.5..4.3...4...8.....73..54.......6.5..1.8.2...1..3...6....5.13..2......
...87........32.....65...7.43....81.8..3.......5.4...7...48....31.2..54..7...6...
..4.......2..7....6734.15.2.4...5.3..96.4.1....7..3.94...31.....6.............9.7
.3..1......29...3..9876....9.5.....6.......2517........6.5..3..3..2..1...5.1.7..2
.........5..8.4...3.....5......78..27593..4..........3..4....3.9.85....6.3.76.9..
9..2......26..5..45..4....9.......35....1...6.35...4.1..2.69...3......8..9...1.6.
7341............96.6...5...471...9......5..8...6......8.....3...49.63..8......149
.419.......9.3.2..3..8.4..67...........6....462..471..1......3......9..8.8.....92
....2...8..54.3...4....6..93.7.......2.......89......4.4...78....265.4.3...3..762
.6.4.8....5..9....39825...1....3.9..2...64..3...5..1.4...8..3......29...9..315..8
.....2.4..6.85...9....3.5.2.859................1..6.532...4..61..3..54.8..9....3.
.8..54...1.56...8......7...9.12.6.......9...864.5.1..24..9..5....2.....9....1...4
.6..............8.......2....1..6..9.....574.752...6...9..58..11.49.2...8..17...6
.............5.24..2.67......68...21..7.........4217..........55.8..63..3.42...1.
....39.......64.........7...5..4..36..6...2..41.3.....1...7...46.2...59.9......2.
...2..1.47...1.........6........9..12..7...3.83.....9.1...8.6...62....8.98...47.3
..2..3.......2..5..3...5.9.....8...33......67.7....4..5.7..2..8.....6..448..3..7.
..4..86..21..........24.97.3..9.21858.5...4...9.4..............6.....5..982.6.3..
45.8...926.........23...4........3....1...2.494.....15...1.95..3..4...8...9.2...1
..94....1.6..95...2....7.95...2.............47.1..9...6......1.4.5.2.....1.8.42.7
    `

	pBuff, allocErr := puzzle_buffer_make()
	defer delete(pBuff)

	testing.expect(
		t,
		allocErr == nil,
		fmt.tprintf("Expected no error (nil) on puzzle_buffer_make(), got %v", allocErr),
	)

	nPuzzles, nLines, err := read_sudoku_file(testFile, &pBuff)
	testing.expect(
		t,
		err == nil,
		fmt.tprintf("Expected no error (nil) on read_sudoku_file(), got %v", err),
	)
	testing.expect(
		t,
		nLines == 100,
		fmt.tprintf("Expected number of lines read from '%v' to be 100, got %v", testFile, nLines),
	)
	testing.expect(
		t,
		nPuzzles == 100,
		fmt.tprintf(
			"Expected number of puzzles parsed from '%v' to be 100, got %v",
			testFile,
			nPuzzles,
		),
	)

	ln := 0
	for line in strings.split_lines_iterator(&dummyFile) {
		if len(line) < 81 do continue
		if ln > 30 do return
		for c, i in line {
			expected: Cell
			switch c {
			case '.':
				expected = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
			case '1' ..= '9':
				expected = cast(u16)c - '0'
			case:
				fmt.panicf("dummyFile had unexpected character at %v:%v, '%v'", ln + 1, i + 1, c)
			}
			actual := pBuff[ln].data[i / 9][i % 9]

			testing.expect(
				t,
				expected == actual,
				fmt.tprintf(
					"dummyFile %v:%v, expected %v, got %v",
					ln + 1,
					i + 1,
					expected,
					actual,
				),
			)
		}
		ln += 1
	}
}
