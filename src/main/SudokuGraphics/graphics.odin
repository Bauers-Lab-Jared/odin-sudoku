package SudokuGraphics

import "../SudokuPuzzle"
import "core:fmt"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

SUDOKU_CELL_SIZE :: 36
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

draw_sudoku_cell :: proc(cell: ^SudokuPuzzle.Cell, #any_int anchor_x, anchor_y: i32) {
	using SudokuPuzzle
	FONT_SIZE :: CHAR_SPACE * 3 / 4
	FONT_SIZE_SOLVED :: SUDOKU_CELL_SIZE * 3 / 4
	CHAR_SPACE :: (SUDOKU_CELL_SIZE) / 3
	draw :: proc(
		text: string,
		anchor_x, anchor_y: i32,
		#any_int row: i32 = 1,
		#any_int col: i32 = 1,
		#any_int font_size: i32 = FONT_SIZE_SOLVED,
		color: rl.Color = {0, 0, 0, 255},
	) {
		rl.DrawText(
			strings.clone_to_cstring(text),
			((anchor_x - 1) + font_size / 2) + (row - 1) * CHAR_SPACE,
			(anchor_y + font_size / 4) + (col - 1) * CHAR_SPACE,
			font_size,
			color,
		)
	}

	rl.DrawRectangle(anchor_x, anchor_y, SUDOKU_CELL_SIZE, SUDOKU_CELL_SIZE, {50, 150, 90, 255})

	buf: [4]byte
	switch c in cell^ {
	case u16:
		switch c {
		case 1 ..= 9:
			draw(strconv.itoa(buf[:], int(c)), anchor_x, anchor_y)
		case:
			draw("?", anchor_x, anchor_y)
		}
	case CellPossibilities:
		for row in 1 ..= 3 {
			for col in 1 ..= 3 {
				pos: int = row + (col - 1) * 3
				if pos in c {
					draw(strconv.itoa(buf[:], pos), anchor_x, anchor_y, row, col, FONT_SIZE)
				}
			}
		}
	case:
		draw("!", anchor_x, anchor_y)
	}
}
