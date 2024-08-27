package SudokuSolver

import "core:fmt"
import "core:io"
import "core:strconv"
import "core:strings"

format_puzzle_str :: proc(puzzle: ^SudokuPuzzle) -> string {

	puzzleStringTemplate := `
     . . . | . . . | . . . 
     . . . | . . . | . . . 
     . . . | . . . | . . . 
    -------|-------|-------
     . . . | . . . | . . . 
     . . . | . . . | . . . 
     . . . | . . . | . . . 
    -------|-------|-------
     . . . | . . . | . . . 
     . . . | . . . | . . . 
     . . . | . . . | . . . 
`

	builder := strings.builder_make(0, len(puzzleStringTemplate))
	defer strings.builder_destroy(&builder)

	cellIndex: int
	for char in puzzleStringTemplate {
		if char == '.' {
			cell, cell_solved := puzzle^.data[cellIndex / 9][cellIndex % 9].(u16)
			if cellIndex < 81 {
				if cell_solved {
					if cell >= 1 && cell <= 9 {
						strings.write_int(&builder, cast(int)cell)
					} else {
						strings.write_byte(&builder, '!')
					}
				} else {
					strings.write_byte(&builder, cast(u8)char)
				}
				cellIndex += 1
			} else {
				strings.write_byte(&builder, '?')
			}
		} else {
			strings.write_byte(&builder, cast(u8)char)
		}
	}
	res := strings.clone(strings.to_string(builder))
	return res
}
