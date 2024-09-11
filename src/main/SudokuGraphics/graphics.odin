package SudokuGraphics

import "../SudokuPuzzle"
import "core:fmt"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

SUDOKU_CELL_SIZE :: 37
SUDOKU_CELL_PAD_INNER :: 1
SUDOKU_CELL_PAD_OUTER :: 2
SUDOKU_CELL_PAD_DIFF :: SUDOKU_CELL_PAD_OUTER - SUDOKU_CELL_PAD_INNER
SCREEN_HEIGHT :: SUDOKU_CELL_SIZE * 9 + SUDOKU_CELL_PAD_INNER * 6 + SUDOKU_CELL_PAD_OUTER * 4

init_sudoku_window :: proc() {
	rl.SetConfigFlags(
		{.VSYNC_HINT, .BORDERLESS_WINDOWED_MODE, .WINDOW_RESIZABLE, .WINDOW_MOUSE_PASSTHROUGH},
	)
	rl.InitWindow(800, 800, "Odin Sudoku")
	rl.SetTargetFPS(60)
	return
}

draw_sudoku_window :: proc(puzzle: ^SudokuPuzzle.Puzzle) {
	rl.BeginDrawing()
	rl.ClearBackground({150, 190, 220, 255})
	screen_height := rl.GetScreenHeight()
	screen_width := rl.GetScreenWidth()
	camera := rl.Camera2D {
		zoom = f32(min(screen_height, screen_width)) / f32(SCREEN_HEIGHT),
	}
	rl.BeginMode2D(camera)

	draw_sudoku_puzzle(
		puzzle,
		i32(f32(screen_width) / (2.0 * camera.zoom)) - SCREEN_HEIGHT / 2 + SUDOKU_CELL_PAD_OUTER,
		i32(f32(screen_height) / (2.0 * camera.zoom)) - SCREEN_HEIGHT / 2 + SUDOKU_CELL_PAD_OUTER,
	)

	rl.EndMode2D()
	rl.EndDrawing()
	return
}

draw_sudoku_puzzle :: proc(puzzle: ^SudokuPuzzle.Puzzle, anchor_x, anchor_y: i32) {
	for row, r in puzzle.data {
		for &cell, c in row {
			draw_sudoku_cell(
				&cell,
				anchor_x +
				i32((SUDOKU_CELL_SIZE + SUDOKU_CELL_PAD_INNER) * c + SUDOKU_CELL_PAD_DIFF * c / 3),
				anchor_y +
				i32((SUDOKU_CELL_SIZE + SUDOKU_CELL_PAD_INNER) * r + SUDOKU_CELL_PAD_DIFF * r / 3),
			)
		}
	}
}

draw_sudoku_cell :: proc(cell: ^SudokuPuzzle.Cell, anchor_x, anchor_y: i32) {
	FONT_SIZE :: CHAR_SPACE * 3 / 4
	CHAR_SPACE :: (SUDOKU_CELL_SIZE - 1) / 3

	using SudokuPuzzle
	rl.DrawRectangle(
		i32(anchor_x),
		i32(anchor_y),
		SUDOKU_CELL_SIZE,
		SUDOKU_CELL_SIZE,
		{50, 150, 90, 255},
	)

	buf: [4]byte
	switch c in cell^ {
	case u16:
		switch c {
		case 1 ..= 9:
			rl.DrawText(
				strings.clone_to_cstring(strconv.itoa(buf[:], int(c))),
				anchor_x + SUDOKU_CELL_SIZE / 2 - FONT_SIZE / 2,
				anchor_y + SUDOKU_CELL_SIZE / 2 - FONT_SIZE,
				FONT_SIZE,
				{0, 0, 0, 255},
			)
		case:
			rl.DrawText(
				"?!",
				anchor_x + SUDOKU_CELL_SIZE / 2 - FONT_SIZE / 2,
				anchor_y + SUDOKU_CELL_SIZE / 2 - FONT_SIZE,
				FONT_SIZE,
				{0, 0, 0, 255},
			)
		}
	case CellPossibilities:
		for row in 1 ..= 3 {
			for col in 1 ..= 3 {
				pos: int = row + (col - 1) * 3
				if pos in c {
					rl.DrawText(
						strings.clone_to_cstring(strconv.itoa(buf[:], pos)),
						(anchor_x + FONT_SIZE / 2) + i32((row - 1) * CHAR_SPACE),
						(anchor_y + FONT_SIZE / 4) + i32((col - 1) * CHAR_SPACE),
						FONT_SIZE,
						{0, 0, 0, 255},
					)
				}
			}
		}
	case:
		rl.DrawText("?!", anchor_x - 2, anchor_y - 4, FONT_SIZE, {0, 0, 0, 255})
	}
}
