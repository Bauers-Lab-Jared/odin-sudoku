package SudokuSolver

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"
import waffle "lib:waffle"

SudokuRead_Error :: union {
	os.Errno,
	runtime.Allocator_Error,
	bool,
}

read_sudoku_file :: proc(
	path: string,
	puzzleBuffer: ^[dynamic]Puzzle,
	allocator := context.allocator,
) -> (
	nPuzzles: int,
	nLines: int,
	err: SudokuRead_Error,
) {
	data := os.read_entire_file(path, allocator) or_return
	defer delete(data)
	puzzle: Puzzle

	iter := string(data)
	iter_loop: for line in strings.split_lines_iterator(&iter) {
		nLines += 1
		if len(line) < 81 do continue

		parse_sudoku_line(&puzzle, line[0:81]) or_continue
		waffle.append_doubling(puzzleBuffer, puzzle, allocator) or_return
		nPuzzles += 1
	}
	return nPuzzles, nLines, err
}

ParseError :: enum {
	None,
	UnexpectedChar,
	StringTooShort,
}

parse_sudoku_line :: proc(puzzle: ^Puzzle, inputLine: string) -> (err: ParseError) {
	puzzle_init(puzzle)
	if len(inputLine) < 81 do return ParseError.StringTooShort

	for c, i in inputLine {
		switch c {
		case '.':
			puzzle[i / 9][i % 9] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
		case '1' ..= '9':
			puzzle[i / 9][i % 9] = cast(u16)c - '0'
		case:
			puzzle_init(puzzle)
			return ParseError.UnexpectedChar
		}
	}
	return ParseError.None
}
