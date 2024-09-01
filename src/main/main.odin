package SudokuSolver

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	printBuilder := strings.builder_make(0, 8192, context.allocator)
	defer strings.builder_destroy(&printBuilder)
	puzzles, _ := puzzle_buffer_make()
	defer delete(puzzles)

	fmt.println("Sudoku Solver")
	nPuzzles, nLines, _ := read_sudoku_file("./test-files/test-puzzles01", &puzzles)


	//	for &puz in puzzles {
	//		make_puzzle_format_builder(&puz, &builder)
	//		fmt.println(strings.to_string(builder))
	//	}

	return
}
