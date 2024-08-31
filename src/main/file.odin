package SudokuSolver

import "core:fmt"
import "core:os"
import "core:strings"

fileRead_Error :: union {
	os.Errno,
	bool,
}

read_sudoku_file :: proc(
	path: string,
	allocator := context.allocator,
) -> (
	puzzleSet: [dynamic]SudokuPuzzle,
	err: fileRead_Error,
) {
	data := os.read_entire_file(path, allocator) or_return

	filePuzzles := make([dynamic]SudokuPuzzle, 0, 100)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) < 81 do continue

		puzzle: SudokuPuzzle
		err := parse_sudoku_line(&puzzle, line[0:81])
		if err == ParseError.None do append(&filePuzzles, puzzle)
	}

	return filePuzzles, err
}

ParseError :: enum {
	None,
	UnexpectedChar,
	StringTooShort,
}

parse_sudoku_line :: proc(puzzle: ^SudokuPuzzle, inputLine: string) -> (err: ParseError) {
	Puzzle_Init(puzzle)
	if len(inputLine) < 81 do return ParseError.StringTooShort

	for c, i in inputLine {
		switch c {
		case '.':
			puzzle.data[i / 9][i % 9] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
		case '1' ..= '9':
			puzzle.data[i / 9][i % 9] = cast(u16)c - '0'
		case:
			Puzzle_Init(puzzle)
			return ParseError.UnexpectedChar
		}
	}
	return ParseError.None
}
