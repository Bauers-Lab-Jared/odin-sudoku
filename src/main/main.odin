package SudokuSolver

import "SudokuFile"
import "SudokuFormat"
import "SudokuPuzzle"
import "core:fmt"
import "core:mem/virtual"
import "core:os"
import "core:strings"

main :: proc() {
	printBuilder := strings.builder_make(0, 8192)
	defer strings.builder_destroy(&printBuilder)
	puzzles, _ := make([dynamic]SudokuPuzzle.Puzzle)
	defer delete(puzzles)

	fmt.println("Sudoku Solver")
	nPuzzles, nLines, _ := SudokuFile.read_sudoku_file("./test-files/test-puzzles01", &puzzles)
	selectedPuzzle := 0


	SudokuFormat.make_puzzle_format_builder_full(&puzzles[selectedPuzzle], &printBuilder)
	fmt.println(strings.to_string(printBuilder))

	return
}
