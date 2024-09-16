package SudokuGraphics

import "../SudokuGame"
import "../SudokuPuzzle"
import "core:fmt"
import "core:math"
import "core:os"
import "core:path/filepath"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

SCREEN_HEIGHT :: SUDOKU_CELL_SIZE * 9 + SUDOKU_CELL_PAD_INNER * 6 + SUDOKU_CELL_PAD_OUTER * 4

COLORS_LIGHT3 :: rl.Color{175, 191, 192, 255}
COLORS_LIGHT2 :: rl.Color{152, 172, 174, 255}
COLORS_LIGHT1 :: rl.Color{129, 153, 156, 255}
COLORS_GRAY :: rl.Color{99, 123, 126, 255}
COLORS_DARK1 :: rl.Color{72, 91, 92, 255}
COLORS_DARK2 :: rl.Color{54, 68, 69, 255}
COLORS_DARK3 :: rl.Color{36, 45, 46, 255}
COLORS_BLUE :: rl.Color{105, 153, 186, 255}
COLORS_GREEN :: rl.Color{81, 152, 71, 255}
COLORS_YELLOW :: rl.Color{250, 197, 99, 255}
COLORS_RED :: rl.Color{242, 170, 205, 255}
COLORS_BLUE_D :: rl.Color{41, 60, 72, 255}
COLORS_GREEN_D :: rl.Color{35, 55, 32, 255}
COLORS_YELLOW_D :: rl.Color{114, 81, 22, 255}
COLORS_RED_D :: rl.Color{123, 38, 79, 255}
COLORS_BLUE_L :: rl.Color{141, 178, 202, 255}
COLORS_GREEN_L :: rl.Color{117, 186, 107, 255}
COLORS_YELLOW_L :: rl.Color{251, 210, 135, 255}
COLORS_RED_L :: rl.Color{245, 191, 217, 255}
COLORS_BLUE_B :: rl.Color{41, 130, 188, 255}
COLORS_GREEN_B :: rl.Color{46, 144, 33, 255}
COLORS_YELLOW_B :: rl.Color{250, 171, 24, 255}
COLORS_RED_B :: rl.Color{241, 85, 161, 255}

WindowData :: struct {
	font:        rl.Font,
	window_size: [2]f32,
	camera:      rl.Camera2D,
}

init_sudoku_window :: proc(windowData: ^WindowData) {
	font_file_path := [2]string {
		filepath.dir(os.args[0]),
		"../Resources/share-tech-mono.regular.ttf",
	}
	defer delete(font_file_path[0])

	rl.SetConfigFlags(
		{
			.VSYNC_HINT,
			.WINDOW_HIGHDPI,
			.WINDOW_UNDECORATED,
			.WINDOW_RESIZABLE,
			.WINDOW_MOUSE_PASSTHROUGH,
		},
	)
	rl.InitWindow(3840, 2160, "Odin Sudoku")
	windowData.font = rl.LoadFontEx(
		strings.clone_to_cstring(filepath.join(font_file_path[:])),
		1024,
		nil,
		250,
	)
	rl.SetTargetFPS(60)
	return
}

close_sudoku_window :: proc(windowData: ^WindowData) {
	rl.UnloadFont(windowData.font)
	rl.CloseWindow()
}

draw_sudoku_window :: proc(gameState: ^SudokuGame.GameState, windowData: ^WindowData) {
	rl.BeginDrawing()
	windowData.window_size.x = f32(rl.GetScreenWidth())
	windowData.window_size.y = f32(rl.GetScreenHeight())
	windowData.camera = rl.Camera2D {
		offset = rl.Vector2{ui_get_hori_offset(windowData), 0.0},
		zoom   = min(windowData.window_size.x, windowData.window_size.y) / f32(SCREEN_HEIGHT),
	}
	rl.BeginMode2D(windowData.camera)

	rl.ClearBackground(COLORS_BLUE_D)

	draw_sudoku_puzzle(gameState, windowData)

	draw_ui_menu(gameState, windowData)

	rl.EndMode2D()
	rl.EndDrawing()
	return
}
