package SudokuGraphics

import "../SudokuPuzzle"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

SUDOKU_CELL_SIZE :: 128
SUDOKU_CELL_PAD_INNER :: 8
SUDOKU_CELL_PAD_OUTER :: 16
SUDOKU_CELL_PAD_DIFF :: SUDOKU_CELL_PAD_OUTER - SUDOKU_CELL_PAD_INNER

draw_sudoku_puzzle :: proc(
	puzzle: ^SudokuPuzzle.Puzzle,
	anchor_x, anchor_y: f32,
	windowData: ^WindowData,
) {
	for row, r in puzzle.data {
		for &cell, c in row {
			draw_sudoku_cell(
				&cell,
				anchor_x +
				f32(
					SUDOKU_CELL_SIZE * c +
					SUDOKU_CELL_PAD_INNER * c +
					SUDOKU_CELL_PAD_DIFF * (c / 3),
				),
				anchor_y +
				f32(
					SUDOKU_CELL_SIZE * r +
					SUDOKU_CELL_PAD_INNER * r +
					SUDOKU_CELL_PAD_DIFF * (r / 3),
				),
				windowData,
			)
		}
	}
}

draw_sudoku_cell :: proc(
	cell: ^SudokuPuzzle.Cell,
	anchor_x, anchor_y: f32,
	windowData: ^WindowData,
) {
	using SudokuPuzzle
	FONT_SIZE :: (SUDOKU_CELL_SIZE) / 3.0
	FONT_SIZE_SOLVED :: SUDOKU_CELL_SIZE
	CHAR_ASPECT_V :: 0.46
	CHAR_ASPECT_H :: 0.24

	DrawInfo :: struct {
		anchor_x, anchor_y: f32,
		font:               rl.Font,
		color:              rl.Color,
	}
	drawInfo := DrawInfo{anchor_x, anchor_y, windowData.font, rl.BLACK}

	draw :: proc(
		drawInfo: ^DrawInfo,
		text: string,
		#any_int row: i32 = 2,
		#any_int col: i32 = 2,
		font_size: f32 = FONT_SIZE_SOLVED,
	) {
		rl.DrawTextEx(
			drawInfo.font,
			strings.clone_to_cstring(text),
			rl.Vector2 {
				drawInfo.anchor_x + f32(col) * (SUDOKU_CELL_SIZE / 4) - CHAR_ASPECT_H * font_size,
				drawInfo.anchor_y + f32(row) * (SUDOKU_CELL_SIZE / 4) - CHAR_ASPECT_V * font_size,
			},
			font_size,
			0.0,
			drawInfo.color,
		)
	}

	{
		_, ok := cell^.(u16)
		cellBGColor: rl.Color = ok ? COLORS_GREEN : COLORS_LIGHT1
		rl.DrawRectangleRounded(
			rl.Rectangle{anchor_x, anchor_y, SUDOKU_CELL_SIZE, SUDOKU_CELL_SIZE},
			0.1,
			1,
			cellBGColor,
		)
	}

	buf: [4]byte
	switch c in cell^ {
	case u16:
		switch c {
		case 1 ..= 9:
			draw(&drawInfo, strconv.itoa(buf[:], int(c)))
		case:
			draw(&drawInfo, "?")
		}
	case CellPossibilities:
		for row in 1 ..= 3 {
			for col in 1 ..= 3 {
				pos: int = row + (col - 1) * 3
				if pos in c {
					draw(&drawInfo, strconv.itoa(buf[:], pos), row, col, FONT_SIZE)
				}
			}
		}
	case:
		draw(&drawInfo, "!")
	}
}
