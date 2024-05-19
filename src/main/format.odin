package sudoku

import "core:strings"

Format_Error :: enum {
	None,
}

FormatPuzzle :: proc(p: SudokuPuzzle) -> (puzzleString: string, err: Format_Error) {
}
