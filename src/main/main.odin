package SudokuSolver

import "SudokuFile"
import "SudokuFormat"
import "SudokuGame"
import "SudokuGraphics"
import "SudokuPuzzle"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import rl "vendor:raylib"

main :: proc() {
	call_path := filepath.dir(os.args[0])
	resources_path := filepath.join([]string{call_path, "../Resources"})

	printBuilder := strings.builder_make(0, 8192)
	defer strings.builder_destroy(&printBuilder)

	gameState: SudokuGame.GameState
	gameState.controlFlags = {.preinit}
	gameState.puzzleStack, _ = make([dynamic]SudokuPuzzle.Puzzle, 0, 32)
	defer delete(gameState.puzzleStack)
	_, _, _ = SudokuFile.read_sudoku_file(
		filepath.join([]string{resources_path, "/puzzles01"}),
		&gameState.puzzleStack,
	)
	SudokuPuzzle.set_workspace_Puzzle(&gameState.workspace, &gameState.puzzleStack[0])

	//	SudokuFormat.make_puzzle_format_builder_full(&puzzles[selectedPuzzle], &printBuilder)
	//	fmt.println(strings.to_string(printBuilder))

	windowData: SudokuGraphics.WindowData

	SudokuGame.game_init(&gameState)
	SudokuGraphics.init_sudoku_window(&windowData, resources_path)

	for !rl.WindowShouldClose() && (.quitting not_in gameState.controlFlags) {
		SudokuGame.run_game_loop(&gameState)

		SudokuGraphics.draw_sudoku_window(&gameState, &windowData)
	}

	SudokuGraphics.close_sudoku_window(&windowData)

	return
}
