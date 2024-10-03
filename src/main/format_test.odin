package SudokuSolver

import "core:fmt"
import "core:io"
import "core:strings"
import "core:testing"

@(test)
test_format_puzzle_str :: proc(t: ^testing.T) {
	using strings
	puzzleDef := `...6928......74..1..5.8.......4.1...6...5.2.....7...6......6..52.4...61.59.....4.`
	printDef := `
     . . . | 6 9 2 | 8 . . 
     . . . | . 7 4 | . . 1 
     . . 5 | . 8 . | . . . 
    -------|-------|-------
     . . . | 4 . 1 | . . . 
     6 . . | . 5 . | 2 . . 
     . . . | 7 . . | . 6 . 
    -------|-------|-------
     . . . | . . 6 | . . 5 
     2 . 4 | . . . | 6 1 . 
     5 9 . | . . . | . 4 . 
`
	puzzle: Puzzle
	parse_sudoku_line(&puzzle, puzzleDef)


	printBuilder := strings.builder_make(0, 8192, context.allocator)
	make_puzzle_format_builder(&puzzle, &printBuilder)
	defer strings.builder_destroy(&printBuilder)
	pString := strings.to_string(printBuilder)

	testing.expect(
		t,
		printDef == pString,
		fmt.tprintf("Expected:\n%v\nGot:\n%v", printDef, pString),
	)
}

@(test)
test_format_puzzle_str_full :: proc(t: ^testing.T) {
	using strings

	puzzleDef := `...6928......74..1..5.8.......4.1...6...5.2.....7...6......6..52.4...61.59.....4.`
	printDef := ` 1 . 3   1 2 3   1 2 3 ║                       ║         1 2 3   1 2 3 
 4 5 . │ 4 5 6 │ 4 5 6 ║   6   │   9   │   2   ║   8   │ 4 5 6 │ 4 5 6 
 7 . .   7 8 9   7 8 9 ║                       ║         7 8 9   7 8 9 
 ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ 
 1 2 3   1 2 3   1 2 3 ║ 1 2 3                 ║ 1 2 3   1 2 3         
 4 5 6 │ 4 5 6 │ 4 5 6 ║ 4 5 6 │   7   │   4   ║ 4 5 6 │ 4 5 6 │   1   
 7 8 9   7 8 9   7 8 9 ║ 7 8 9                 ║ 7 8 9   7 8 9         
 ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ 
 1 2 3   1 2 3         ║ 1 2 3           1 2 3 ║ 1 2 3   1 2 3   1 2 3 
 4 5 6 │ 4 5 6 │   5   ║ 4 5 6 │   8   │ 4 5 6 ║ 4 5 6 │ 4 5 6 │ 4 5 6 
 7 8 9   7 8 9         ║ 7 8 9           7 8 9 ║ 7 8 9   7 8 9   7 8 9 
═══════════════════════╬═══════════════════════╬═══════════════════════
 1 2 3   1 2 3   1 2 3 ║         1 2 3         ║ 1 2 3   1 2 3   1 2 3 
 4 5 6 │ 4 5 6 │ 4 5 6 ║   4   │ 4 5 6 │   1   ║ 4 5 6 │ 4 5 6 │ 4 5 6 
 7 8 9   7 8 9   7 8 9 ║         7 8 9         ║ 7 8 9   7 8 9   7 8 9 
 ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ 
         1 2 3   1 2 3 ║ 1 2 3           1 2 3 ║         1 2 3   1 2 3 
   6   │ 4 5 6 │ 4 5 6 ║ 4 5 6 │   5   │ 4 5 6 ║   2   │ 4 5 6 │ 4 5 6 
         7 8 9   7 8 9 ║ 7 8 9           7 8 9 ║         7 8 9   7 8 9 
 ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ 
 1 2 3   1 2 3   1 2 3 ║         1 2 3   1 2 3 ║ 1 2 3           1 2 3 
 4 5 6 │ 4 5 6 │ 4 5 6 ║   7   │ 4 5 6 │ 4 5 6 ║ 4 5 6 │   6   │ 4 5 6 
 7 8 9   7 8 9   7 8 9 ║         7 8 9   7 8 9 ║ 7 8 9           7 8 9 
═══════════════════════╬═══════════════════════╬═══════════════════════
 1 2 3   1 2 3   1 2 3 ║ 1 2 3   1 2 3         ║ 1 2 3   1 2 3         
 4 5 6 │ 4 5 6 │ 4 5 6 ║ 4 5 6 │ 4 5 6 │   6   ║ 4 5 6 │ 4 5 6 │   5   
 7 8 9   7 8 9   7 8 9 ║ 7 8 9   7 8 9         ║ 7 8 9   7 8 9         
 ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ 
         1 2 3         ║ 1 2 3   1 2 3   1 2 3 ║                 1 2 3 
   2   │ 4 5 6 │   4   ║ 4 5 6 │ 4 5 6 │ 4 5 6 ║   6   │   1   │ 4 5 6 
         7 8 9         ║ 7 8 9   7 8 9   7 8 9 ║                 7 8 9 
 ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ ║ ─ ─ ─ ┼ ─ ─ ─ ┼ ─ ─ ─ 
                 1 2 3 ║ 1 2 3   1 2 3   1 2 3 ║ 1 2 3           1 2 3 
   5   │   9   │ 4 5 6 ║ 4 5 6 │ 4 5 6 │ 4 5 6 ║ 4 5 6 │   4   │ 4 5 6 
                 7 8 9 ║ 7 8 9   7 8 9   7 8 9 ║ 7 8 9           7 8 9 `

	puzzle: Puzzle
	parse_sudoku_line(&puzzle, puzzleDef)
	switch &c in puzzle.data[0][0] {
	case u16:
	case CellPossibilities:
		c -= CellPossibilities{6, 9, 2, 8}
	}

	builder := strings.builder_make(0, 8192)
	defer strings.builder_destroy(&builder)
	make_puzzle_format_builder_full(&puzzle, &builder)
	pString := strings.to_string(builder)

	testing.expect(
		t,
		printDef == pString,
		fmt.tprintf("Expected:\n%v\nGot:\n%v", printDef, pString),
	)
}
