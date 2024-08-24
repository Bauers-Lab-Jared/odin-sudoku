package sudoku

import "core:fmt"
import "core:os"

main :: proc() {
	fmt.println("Sudoku Solver")
	puzzles, err := read_sudoku_file(os.args[1])
	for puz in puzzles {fmt.print(format_puzzle_str(puz))}
	return
}
