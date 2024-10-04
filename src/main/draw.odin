package SudokuSolver

import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

SUDOKU_CELL_SIZE :: 128
SUDOKU_CELL_PAD_INNER :: 8
SUDOKU_CELL_PAD_OUTER :: 16
SUDOKU_CELL_PAD_DIFF :: SUDOKU_CELL_PAD_OUTER - SUDOKU_CELL_PAD_INNER
SUDOKU_CELL_TEXT_NORMAL_COLOR :: rl.BLACK
SUDOKU_CELL_TEXT_HIGHLIGHT_REMOVE_COLOR :: COLORS_RED_B
SUDOKU_CELL_TEXT_HIGHLIGHT_REF_COLOR :: COLORS_YELLOW_B
SUDOKU_CELL_SELECTED_COLOR :: COLORS_BLUE
SUDOKU_GROUP_SELECTED_COLOR :: COLORS_BLUE_L
SUDOKU_CELL_UNSELECTED_COLOR :: COLORS_LIGHT1
SUDOKU_CELL_SOLVED_COLOR :: COLORS_GREEN_L
SUDOKU_CELL_HIGHLIGHT_CHANGE_COLOR :: COLORS_RED_L
SUDOKU_CELL_HIGHLIGHT_REF_COLOR :: COLORS_YELLOW_L

draw_sudoku_puzzle :: proc(gameState: ^GameState, windowData: ^WindowData) {
	anchor: [2]f32
	anchor.x =
		(windowData.window_size.x / (2.0 * windowData.camera.zoom)) -
		SCREEN_HEIGHT / 2 +
		SUDOKU_CELL_PAD_OUTER
	anchor.y =
		(windowData.window_size.y / (2.0 * windowData.camera.zoom)) -
		SCREEN_HEIGHT / 2 +
		SUDOKU_CELL_PAD_OUTER

	drawOpts: DrawOpts

	for row, r in gameState.workspace.puzzle {
		for &cell, c in row {
			drawOpts = get_draw_opts(
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
			)

			draw_sudoku_cell(&cell, &drawOpts)
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
draw_sudoku_cell :: proc(cell: ^Cell, drawOpts: ^DrawOpts) {
	FONT_SIZE :: (SUDOKU_CELL_SIZE) / 3.0
	FONT_SIZE_SOLVED :: SUDOKU_CELL_SIZE
	CHAR_ASPECT_V :: 0.46
	CHAR_ASPECT_H :: 0.24

	draw :: proc(
		drawOpts: ^DrawOpts,
		text: string,
		colorIndex: int = 0,
		#any_int row: i32 = 2,
		#any_int col: i32 = 2,
		font_size: f32 = FONT_SIZE_SOLVED,
	) {
		rl.DrawTextEx(
			drawOpts.font,
			strings.clone_to_cstring(text),
			rl.Vector2 {
				drawOpts.anchor.x + f32(col) * (SUDOKU_CELL_SIZE / 4) - CHAR_ASPECT_H * font_size,
				drawOpts.anchor.y + f32(row) * (SUDOKU_CELL_SIZE / 4) - CHAR_ASPECT_V * font_size,
			},
			font_size,
			0.0,
			drawOpts.numColors[colorIndex],
		)
	}

	rl.DrawRectangleRounded(
		rl.Rectangle{drawOpts.anchor.x, drawOpts.anchor.y, SUDOKU_CELL_SIZE, SUDOKU_CELL_SIZE},
		0.1,
		1,
		drawOpts.cellColor,
	)

	buf: [4]byte
	switch c in cell^ {
	case u16:
		switch c {
		case 1 ..= 9:
			draw(drawOpts, strconv.itoa(buf[:], int(c)))
		case:
			draw(drawOpts, "?")
		}
	case CellPossibilities:
		for row in 1 ..= 3 {
			for col in 1 ..= 3 {
				pos: int = col + (3 - row) * 3
				if pos in c {
					draw(drawOpts, strconv.itoa(buf[:], pos), pos - 1, row, col, FONT_SIZE)
				}
			}
		}
	case:
		draw(drawOpts, "!")
	}
}

@(private)
get_draw_opts :: proc(
	#any_int row, col: u8,
	anchor: [2]f32,
	gameState: ^GameState,
	windowData: ^WindowData,
) -> (
	drawOpts: DrawOpts,
) {
	drawOpts.anchor = anchor
	drawOpts.font = windowData.font

	removedPossibilities: CellPossibilities
	refPossibilities: CellPossibilities

	switch c in gameState.workspace.puzzle[row][col] {
	case CellPossibilities:
		drawOpts.cellColor = SUDOKU_CELL_UNSELECTED_COLOR
	case u16:
		drawOpts.cellColor = SUDOKU_CELL_SOLVED_COLOR
	case:
		drawOpts.cellColor = COLORS_RED_B
	}

	for refCell in gameState.uiState.highlightAction.inRefTo {
		if refCell == {} do continue

		if refCell.row == row && refCell.col == col {
			drawOpts.cellColor = SUDOKU_CELL_HIGHLIGHT_REF_COLOR
			if p, ok := refCell.refValues.x.(CellPossibilities); ok {
				refPossibilities = p
			}
		}
	}

	for changedCell in gameState.uiState.highlightAction.changed {
		if changedCell == {} do continue

		if changedCell.row == row && changedCell.col == col {
			drawOpts.cellColor = SUDOKU_CELL_HIGHLIGHT_CHANGE_COLOR
			if p, ok := changedCell.refValues.x.(CellPossibilities); ok {
				removedPossibilities = p
			}
		}
	}

	{
		using gameState.uiState.sudokuSel
		if coords.row < 9 && coords.col < 9 {
			switch group {
			case .None:
			case .Row:
				if coords.row == row do drawOpts.cellColor = SUDOKU_GROUP_SELECTED_COLOR
			case .Col:
				if coords.col == col do drawOpts.cellColor = SUDOKU_GROUP_SELECTED_COLOR
			case .Sqr:
				if coords.row / 3 == row / 3 && coords.col / 3 == col / 3 do drawOpts.cellColor = SUDOKU_GROUP_SELECTED_COLOR
			case:
			}
			if coords.row == row && coords.col == col do drawOpts.cellColor = SUDOKU_CELL_SELECTED_COLOR
		}
	}

	for n in 1 ..= 9 {
		if n in refPossibilities {
			drawOpts.numColors[n - 1] = SUDOKU_CELL_TEXT_HIGHLIGHT_REF_COLOR
		} else {
			drawOpts.numColors[n - 1] = SUDOKU_CELL_TEXT_NORMAL_COLOR
		}

		if n in removedPossibilities {
			drawOpts.numColors[n - 1] = SUDOKU_CELL_TEXT_HIGHLIGHT_REMOVE_COLOR
		}
	}

	return drawOpts
}
