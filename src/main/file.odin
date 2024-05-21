package sudoku

import "core:fmt"
import "core:os"
import "core:strings"

fileRead_Error :: union {
	os.Errno,
	bool,
}

readSudokuFile :: proc(path: string) -> (puzzleSet: [dynamic]SudokuPuzzle, err: fileRead_Error) {
	data := os.read_entire_file(path, context.allocator) or_return
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
	puzzle: [81]Cell

	if len(inputLine) < 81 do return {}, ParseError.StringTooShort

	for c, i in inputLine {
		switch c {
		case '.':
			puzzle[i].possible = 511 //1..=9 possible
		case '1' ..= '9':
			puzzle[i].value = cast(u8)c - '0'
		case:
			return transmute(SudokuPuzzle)puzzle, ParseError.UnexpectedChar
		}
	}
	return transmute(SudokuPuzzle)puzzle, ParseError.None
}
