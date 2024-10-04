package SudokuSolver

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

	gameState: GameState
	gameState.controlFlags = {.preinit}
	gameState.puzzleStack, _ = make([dynamic]Puzzle, 0, 32)
	defer delete(gameState.puzzleStack)
	_, _, _ = read_sudoku_file(
		filepath.join([]string{resources_path, "/puzzles01"}),
		&gameState.puzzleStack,
	)
	if len(gameState.puzzleStack) < 1 do append_elem(&gameState.puzzleStack, puzzle_init(new(Puzzle))^)
	ws_set_puzzle(&gameState.workspace, &gameState.puzzleStack[0])

	//	make_puzzle_format_builder_full(&puzzles[selectedPuzzle], &printBuilder)
	//	fmt.println(strings.to_string(printBuilder))

	windowData: WindowData

	game_init(&gameState)
	init_sudoku_window(&windowData, resources_path)

	for !rl.WindowShouldClose() && (.quitting not_in gameState.controlFlags) {
		run_game_loop(&gameState)

		draw_sudoku_window(&gameState, &windowData)
	}

	close_sudoku_window(&windowData)

	return
}
