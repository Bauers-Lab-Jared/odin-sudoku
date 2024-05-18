package sudoku

import "core:fmt"
import "core:os"
import "core:strings"

fileRead_Error :: union {
	os.Errno,
	bool,
}

readSudokuFile :: proc(path: string) -> (puzzleSet: [dynamic]SudokuPuzzle, err: fileRead_Error) {
	data, ok := os.read_entire_file(path, context.allocator)
	if !ok {
		return nil, false
	}
	defer delete(data, context.allocator)

	filePuzzles := make([dynamic]SudokuPuzzle, 0, 100)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) < 81 do continue

		p, err := parseSudoku_line(line[0:81])
		if err == ParseError.None do append(&filePuzzles, p)
	}

	return filePuzzles, err
}

ParseError :: enum {
	None,
	UnexpectedChar,
	StringTooShort,
}

parseSudoku_line :: proc(inputLine: string) -> (out: SudokuPuzzle, err: ParseError) {
	puzzle: SudokuPuzzle

	if len(inputLine) < 81 do return puzzle, ParseError.StringTooShort

	for c, i in inputLine {
		switch c {
		case '.':
			puzzle.cells[i] = 0
		case '1' ..= '9':
			puzzle.cells[i] = cast(u8)c - '0'
		case:
			return puzzle, ParseError.UnexpectedChar
		}
	}
	return puzzle, ParseError.None
}
