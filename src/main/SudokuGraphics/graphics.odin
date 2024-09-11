package SudokuGraphics

import rl "vendor:raylib"

init_sudoku_window :: proc() {
	rl.SetConfigFlags(
		{.VSYNC_HINT, .BORDERLESS_WINDOWED_MODE, .WINDOW_RESIZABLE, .WINDOW_MOUSE_PASSTHROUGH},
	)
	rl.InitWindow(800, 800, "Odin Sudoku")
	rl.SetTargetFPS(60)
	return
}

draw_sudoku_window :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground({150, 190, 220, 255})
	rl.EndDrawing()
	return
}
