package format

import "../file"
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
	puzzle, _ := file.parse_sudoku_line(puzzleDef)
	pString := format_puzzle_str(&puzzle)

	testing.expect(
		t,
		printDef == pString,
		fmt.tprintf("Expected:\n%v\nGot:\n%v", printDef, pString),
	)
}
