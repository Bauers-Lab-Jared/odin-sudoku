package SudokuGraphics

import "../SudokuGame"
import "../SudokuPuzzle"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

SUDOKU_CELL_SIZE :: 128
SUDOKU_CELL_PAD_INNER :: 8
SUDOKU_CELL_PAD_OUTER :: 16
SUDOKU_CELL_PAD_DIFF :: SUDOKU_CELL_PAD_OUTER - SUDOKU_CELL_PAD_INNER
SUDOKU_SELECTION_COLOR :: COLORS_GREEN_L
SUDOKU_HIGHLIGHT_CHANGE_COLOR :: COLORS_RED_L
SUDOKU_HIGHLIGHT_REF_COLOR :: COLORS_YELLOW_L

draw_sudoku_puzzle :: proc(gameState: ^SudokuGame.GameState, windowData: ^WindowData) {
	anchor: [2]f32
	anchor.x =
		(windowData.window_size.x / (2.0 * windowData.camera.zoom)) -
		SCREEN_HEIGHT / 2 +
		SUDOKU_CELL_PAD_OUTER
	anchor.y =
		(windowData.window_size.y / (2.0 * windowData.camera.zoom)) -
		SCREEN_HEIGHT / 2 +
		SUDOKU_CELL_PAD_OUTER

	for row, r in gameState.workspace.puzzle.data {
		for &cell, c in row {
			draw_sudoku_cell(
				&cell,
				get_draw_opts(
					r,
					c,
					[2]f32 {
						anchor.x +
						f32(
							SUDOKU_CELL_SIZE * c +
							SUDOKU_CELL_PAD_INNER * c +
							SUDOKU_CELL_PAD_DIFF * (c / 3),
						),
						anchor.y +
						f32(
							SUDOKU_CELL_SIZE * r +
							SUDOKU_CELL_PAD_INNER * r +
							SUDOKU_CELL_PAD_DIFF * (r / 3),
						),
					},
					gameState,
					windowData,
				),
			)
		}
	}
}

@(private)
DrawOpts :: struct {
	cellColor: rl.Color,
	numColors: [9]rl.Color,
	font:      rl.Font,
	anchor:    [2]f32,
}

@(private)
draw_sudoku_cell :: proc(cell: ^SudokuPuzzle.Cell, drawOpts: DrawOpts) {
	using SudokuPuzzle
	FONT_SIZE :: (SUDOKU_CELL_SIZE) / 3.0
	FONT_SIZE_SOLVED :: SUDOKU_CELL_SIZE
	CHAR_ASPECT_V :: 0.46
	CHAR_ASPECT_H :: 0.24

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

@(private)
get_draw_opts :: proc(
	#any_int row, col: int,
	anchor: [2]f32,
	gameState: ^SudokuGame.GameState,
	windowData: ^WindowData,
) -> (
	drawOpts: DrawOpts,
) {
	drawOpts.anchor = anchor
	drawOpts.font = windowData.font

	removedPossibilities: CellPossibilities
	refPossibilities: CellPossibilities

	for refCell in gameState.uiState.highlightAction.inRefTo {
		if refCell == nil do continue

		if refCell.row == row && refCell.col == col {
			drawOpts.cellColor = SUDOKU_HIGHLIGHT_REF_COLOR
			if refCell.refValues != nil {
				refPossibilities = changedCell.refValues.x
			}
		}
	}

	for changedCell in gameState.uiState.highlightAction.changed {
		if changedCell == nil do continue

		if changedCell.row == row && changedCell.col == col {
			drawOpts.cellColor = SUDOKU_HIGHLIGHT_CHANGE_COLOR
			if changedCell.refValues != nil {
				removedPossibilities = changedCell.refValues.x
			}
		}
	}

	switch sel in gameState.uiState.sudokuSel {
	case SudokuPuzzle.CellCoords:
		if sel.x == row && sel.y == col do drawOpts.cellColor = SUDOKU_SELECTION_COLOR
	case RowNum:
    if sel.y ==
	case ColNum:
	case SqrNum:
	}
}
