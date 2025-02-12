package SudokuSolver

import "core:fmt"
import "core:math"
import "core:strconv"
import "core:strings"
import waffle "lib:waffle"
import rl "vendor:raylib"

UI_SIDE_BAR_WIDTH :: 3 * SUDOKU_CELL_SIZE
UI_SIDE_BAR_SLIDEOUT :: UI_SIDE_BAR_WIDTH + SUDOKU_CELL_PAD_OUTER
UI_SIDE_BAR_SLIDEOUT_TRIG_START :: SUDOKU_CELL_SIZE * 3 - UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH
UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH :: SUDOKU_CELL_SIZE / 3

ui_get_hori_offset :: proc(windowData: ^WindowData, forceShowMenu := false) -> (offset: f32) {
	if !forceShowMenu && f32(rl.GetMouseX()) > windowData.window_size.x do return

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
		if forceShowMenu {
			offset = -slideout
		} else {
			offset =
				(-slideout *
					clamp(
						f32(rl.GetMouseX()) / windowData.camera.zoom -
						((windowData.window_size.x / 2) / windowData.camera.zoom +
								UI_SIDE_BAR_SLIDEOUT_TRIG_START),
						0.0,
						UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH,
					) /
					UI_SIDE_BAR_SLIDEOUT_TRIG_WIDTH)
		}
	}

	return
}

draw_ui_menu :: proc(gameState: ^GameState, windowData: ^WindowData) {
	anchor: rl.Vector2
	anchor.x = windowData.window_size.x / (2.0 * windowData.camera.zoom) + SCREEN_HEIGHT / 2
	anchor.y =
		windowData.window_size.y / (2.0 * windowData.camera.zoom) -
		SCREEN_HEIGHT / 2 +
		SUDOKU_CELL_PAD_OUTER

	rl.DrawRectangleRounded(
		rl.Rectangle {
			anchor.x,
			anchor.y,
			UI_SIDE_BAR_WIDTH,
			SCREEN_HEIGHT - 2 * SUDOKU_CELL_PAD_OUTER,
		},
		0.1,
		1,
		COLORS_GRAY,
	)

	rl.DrawRectangleRec(
		rl.Rectangle {
			anchor.x + SUDOKU_CELL_PAD_OUTER,
			anchor.y + SUDOKU_CELL_PAD_OUTER * 2,
			UI_SIDE_BAR_WIDTH - SUDOKU_CELL_PAD_OUTER,
			SUDOKU_CELL_SIZE / 2.5,
		},
		COLORS_YELLOW,
	)

	rl.DrawTextEx(
		windowData.font,
		strings.clone_to_cstring(gameState.uiState.menuState.current.text),
		anchor + SUDOKU_CELL_PAD_OUTER * 2,
		SUDOKU_CELL_SIZE / 2.5,
		1,
		rl.BLACK,
	)

	for &butt, i in gameState.uiState.menuState.current.buttons {
		draw_ui_menu_button(
			&butt,
			i,
			windowData,
			gameState,
			rl.Vector2 {
				anchor.x + SUDOKU_CELL_PAD_OUTER,
				anchor.y + (SUDOKU_CELL_PAD_OUTER + SUDOKU_CELL_SIZE / 2.5) * f32(i + 2),
			},
			rl.Vector2{UI_SIDE_BAR_WIDTH - SUDOKU_CELL_PAD_OUTER, SUDOKU_CELL_SIZE / 2.5},
		)
	}
}

draw_ui_menu_button :: proc(
	butt: ^Button,
	#any_int index: u8,
	windowData: ^WindowData,
	gameState: ^GameState,
	anchor: rl.Vector2,
	size: rl.Vector2,
) {
	color: rl.Color
	if m := (rl.GetMousePosition() - windowData.camera.offset) / windowData.camera.zoom;
	   waffle.is_inside_rectangle(m, anchor, anchor + size) {
		color = COLORS_GREEN
		gameState.uiState.menuState.mouseOverBtn = butt
	} else if index == gameState.uiState.menuState.current.selected {
		color = COLORS_GREEN
	} else {
		color = COLORS_BLUE_B
	}

	rl.DrawRectangleV(anchor, size, color)

	rl.DrawTextEx(
		windowData.font,
		strings.clone_to_cstring(butt.text),
		anchor,
		size.y,
		1,
		rl.BLACK,
	)
}
