package SudokuSolver

import "SudokuFile"
import "SudokuFormat"
import "SudokuGame"
import "SudokuGraphics"
import "SudokuPuzzle"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

main :: proc() {
	printBuilder := strings.builder_make(0, 8192)
	defer strings.builder_destroy(&printBuilder)
	puzzles, _ := make([dynamic]SudokuPuzzle.Puzzle)
	defer delete(puzzles)

	nPuzzles, nLines, _ := SudokuFile.read_sudoku_file("./test-files/test-puzzles01", &puzzles)
	selectedPuzzle := 0


	//	SudokuFormat.make_puzzle_format_builder_full(&puzzles[selectedPuzzle], &printBuilder)
	//	fmt.println(strings.to_string(printBuilder))

	gameState: SudokuGame.GameState
	windowData: SudokuGraphics.WindowData

	SudokuPuzzle.set_workspace_Puzzle(&gameState.workspace, &puzzles[selectedPuzzle])

	SudokuGame.game_init(&gameState)
	SudokuGraphics.init_sudoku_window(&windowData)

	for !rl.WindowShouldClose() {
		SudokuGame.run_game_loop(&gameState)

		SudokuGraphics.draw_sudoku_window(&gameState, &windowData)
	}

	SudokuGraphics.close_sudoku_window(&windowData)

	return
}
