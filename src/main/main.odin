package SudokuSolver

import "core:fmt"
import "core:os"

main :: proc() {
	fmt.println("Sudoku Solver")
	puzzles, _ := read_sudoku_file("./test-files/test-puzzles01")
	defer delete(puzzles)
	for &puz in puzzles {fmt.print(format_puzzle_str(&puz))}
	return
}
