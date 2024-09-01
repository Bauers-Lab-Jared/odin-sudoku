package SudokuSolver

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	fmt.println("Sudoku Solver")
	puzzles, _ := read_sudoku_file("./test-files/test-puzzles01")
	defer delete(puzzles)

	builder: strings.Builder
	defer strings.builder_destroy(&builder)

	for &puz in puzzles {
		make_puzzle_format_builder(&puz, builder)
		fmt.println(strings.to_string(builder))
	}
	return
}
