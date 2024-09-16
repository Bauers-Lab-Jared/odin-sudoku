package SudokuGraphics

import "../SudokuGame"
import "core:math"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

UI_SIDE_BAR_WIDTH :: 3 * SUDOKU_CELL_SIZE
UI_SIDE_BAR_SLIDEOUT :: UI_SIDE_BAR_WIDTH + SUDOKU_CELL_PAD_OUTER
UI_SIDE_BAR_SLIDEOUT_TRIG_START :: SUDOKU_CELL_SIZE * 3 - UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH
UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH :: SUDOKU_CELL_SIZE / 3

ui_get_hori_offset :: proc(windowData: ^WindowData) -> f32 {
	if f32(rl.GetMouseX()) > windowData.window_size.x do return 0

	slideout: f32
	switch {
	case windowData.window_size.x <= windowData.window_size.y:
		slideout = UI_SIDE_BAR_SLIDEOUT * windowData.camera.zoom
	case windowData.window_size.y / windowData.camera.zoom >
	     SCREEN_HEIGHT + UI_SIDE_BAR_SLIDEOUT * 2:
		slideout = 0
	case:
		slideout =
			UI_SIDE_BAR_SLIDEOUT * windowData.camera.zoom -
			(windowData.window_size.x - windowData.window_size.y) / 2
	}


	if slideout > 0 {
		return(
			-slideout *
			clamp(
				f32(rl.GetMouseX()) / windowData.camera.zoom -
				((windowData.window_size.x / 2) / windowData.camera.zoom +
						UI_SIDE_BAR_SLIDEOUT_TRIG_START),
				0.0,
				UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH,
			) /
			UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH \
		)
	}

	return 0
}

draw_ui_menu :: proc(gameState: ^SudokuGame.GameState, windowData: ^WindowData) {
	rl.DrawRectangleRounded(
		rl.Rectangle {
			windowData.window_size.x / (2.0 * windowData.camera.zoom) + SCREEN_HEIGHT / 2,
			windowData.window_size.y / (2.0 * windowData.camera.zoom) -
			SCREEN_HEIGHT / 2 +
			SUDOKU_CELL_PAD_OUTER,
			UI_SIDE_BAR_WIDTH,
			SCREEN_HEIGHT - 2 * SUDOKU_CELL_PAD_OUTER,
		},
		0.1,
		1,
		COLORS_GRAY,
	)
}
