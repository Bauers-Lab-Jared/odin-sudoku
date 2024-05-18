package file

import "core:fmt"
import "core:os"
import "core:strings"

fileRead_Error :: union {
	os.Errno,
}

readSudokuFile :: proc(path: string) -> (puzzleSet: [dynamic]SudokuPuzzle, err: fileRead_Error) {
	data, ok := os.read_entire_file(path, context.allocator)
	if !ok {
		return nil, path
	}
	defer delete(data, context.allocator)

	it := string(data)

	filePuzzles := make([dynamic]SudokuPuzzle, 0, 100)
	iterate_puzzles: for str in strings.split_lines_iterator(&it) {
		puzzle: SudokuPuzzle
		for i in 0 ..< 81 {
			switch str[i] {
			case '.':
				puzzle.cells[i] = 0
			case '1' ..= '9':
				puzzle.cells[i] = str[i] - '0'
			case:
				continue iterate_puzzles
			}
		}
		append(&filePuzzles, puzzle)
	}

	return filePuzzles, err
}

parseSudoku_line :: proc(inputLine: [81]u8) -> (out: SudokuPuzzle, err: ParseError) {
}
