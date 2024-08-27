package file

import "../puzzle"
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
	puzzleSet: [dynamic]puzzle.SudokuPuzzle,
	err: fileRead_Error,
) {
	using puzzle
	data := os.read_entire_file(path, allocator) or_return

	filePuzzles := make([dynamic]SudokuPuzzle, 0, 100)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) < 81 do continue

		p, err := parse_sudoku_line(line[0:81])
		if err == ParseError.None do append(&filePuzzles, p)
	}

	return filePuzzles, err
}

ParseError :: enum {
	None,
	UnexpectedChar,
	StringTooShort,
}

parse_sudoku_line :: proc(inputLine: string) -> (out: puzzle.SudokuPuzzle, err: ParseError) {
	using puzzle
	if len(inputLine) < 81 do return {}, ParseError.StringTooShort

	for c, i in inputLine {
		switch c {
		case '.':
			out.data[i / 9][i % 9] = CellPossibilities{1, 2, 3, 4, 5, 6, 7, 8, 9}
		case '1' ..= '9':
			out.data[i / 9][i % 9] = cast(u16)c - '0'
		case:
			return out, ParseError.UnexpectedChar
		}
	}
	return out, ParseError.None
}
