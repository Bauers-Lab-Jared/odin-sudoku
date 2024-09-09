package SudokuGraphics

import rl "vendor:raylib"

init_sudoku_window :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(1280, 1280, "Odin Sudoku")
	rl.SetTargetFPS(60)
	return
}

draw_sudoku_window :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground({150, 190, 220, 255})
	rl.EndDrawing()
	return
}
