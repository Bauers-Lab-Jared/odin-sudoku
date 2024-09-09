package SudokuSolver

import "core:fmt"
import "core:mem/virtual"
import "core:os"
import "core:strings"

main :: proc() {
	printBuilder := strings.builder_make(0, 8192)
	defer strings.builder_destroy(&printBuilder)
	puzzles, _ := make([dynamic]SudokuPuzzle)
	defer delete(puzzles)

	fmt.println("Sudoku Solver")
	nPuzzles, nLines, _ := read_sudoku_file("./test-files/test-puzzles01", &puzzles)
	selectedPuzzle := 0


	make_puzzle_format_builder_full(&puzzles[selectedPuzzle], &printBuilder)
	fmt.println(strings.to_string(printBuilder))

	return
}
