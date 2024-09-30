package SudokuGame

import "../SudokuPuzzle"
import "core:fmt"
import rl "vendor:raylib"

InputMode :: enum {
	normal,
	jump,
	modify,
}

ScreenView :: enum {
	menu,
	workspace,
}

UIState :: struct {
	sudokuSel:       SudokuPuzzle.Selection,
	highlightAction: SudokuPuzzle.SudokuAction,
	inputMode:       InputMode,
	currentView:     ScreenView,
	menuState:       MenuState,
}

init_ui :: proc(gameState: ^GameState, allocator := context.allocator) {
	using gameState.uiState
	init_menu(gameState, allocator)

	sudokuSel.group = .None
	sudokuSel.coords = { 	// 9 is used for no selection
		row = 9,
		col = 9,
	}

}

@(private)
GameControls :: enum {
	NONE,
	MODE_MODIFY,
	MODE_NORMAL,
	SELECT_ROWS,
	SELECT_COLS,
	SELECT_SQRS,
	LEFT,
	RIGHT,
	UP,
	DOWN,
	ZERO,
	ONE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	ACCEPT,
	BACK,
}

@(private)
controlMap := map[rl.KeyboardKey]GameControls {
	.SPACE = .ACCEPT,
	.ENTER = .MODE_MODIFY,
	.R     = .SELECT_ROWS,
	.C     = .SELECT_COLS,
	.S     = .SELECT_SQRS,
	.LEFT  = .LEFT,
	.RIGHT = .RIGHT,
	.UP    = .UP,
	.DOWN  = .DOWN,
	.ZERO  = .ZERO,
	.ONE   = .ONE,
	.TWO   = .TWO,
	.THREE = .THREE,
	.FOUR  = .FOUR,
	.FIVE  = .FIVE,
	.SIX   = .SIX,
	.SEVEN = .SEVEN,
	.EIGHT = .EIGHT,
	.NINE  = .NINE,
	.KP_0  = .ZERO,
	.KP_1  = .ONE,
	.KP_2  = .TWO,
	.KP_3  = .THREE,
	.KP_4  = .FOUR,
	.KP_5  = .FIVE,
	.KP_6  = .SIX,
	.KP_7  = .SEVEN,
	.KP_8  = .EIGHT,
	.KP_9  = .NINE,
}

game_handle_input :: proc(using uiState: ^UIState) -> (req: UserAction) {
	if key := rl.GetKeyPressed(); key != .KEY_NULL {
		switch gameControl := controlMap[key]; gameControl {
		case {}:
		case .ZERO, .ONE, .TWO, .THREE, .FOUR, .FIVE, .SIX, .SEVEN, .EIGHT, .NINE:
			n: int
			#partial switch gameControl {
			case .NINE:
				n = 9
			case .EIGHT:
				n = 8
			case .SEVEN:
				n = 7
			case .SIX:
				n = 6
			case .FIVE:
				n = 5
			case .FOUR:
				n = 4
			case .THREE:
				n = 3
			case .TWO:
				n = 2
			case .ONE:
				n = 1
			case .ZERO:
				n = 0
			}
			req = control_number_handler(n, uiState)
		case .LEFT, .RIGHT, .UP, .DOWN:
			control_direction_handler(gameControl, uiState)
		case .ACCEPT:
		case .MODE_NORMAL:
			control_set_inputMode(.normal, uiState)
		case .MODE_MODIFY:
			control_set_inputMode(.modify, uiState)
		case .SELECT_ROWS:
			selection_set_group(.Row, &sudokuSel)
		case .SELECT_COLS:
			selection_set_group(.Col, &sudokuSel)
		case .SELECT_SQRS:
			selection_set_group(.Sqr, &sudokuSel)
		case .BACK:
		}
	}
	return req
}

control_number_handler :: proc(#any_int num: u8, using uiState: ^UIState) -> (req: UserAction) {
	switch inputMode {
	case .normal:
		selection_goto(num, uiState)
		if num > 0 && sudokuSel.group == .None {
			inputMode = .jump
		}
	case .jump:
		selection_goto(num, uiState)
		inputMode = .normal
	case .modify:
		req = Action_Toggle(u16(num))
	case:
	}
	return req
}

control_set_inputMode :: proc(mode: InputMode, using uiState: ^UIState) {
	if inputMode == mode {
		inputMode = .normal
	} else {
		inputMode = mode
	}
}

control_direction_handler :: proc(dir: GameControls, uiState: ^UIState) {
	#partial switch dir {
	case .LEFT:
		selection_move(0, -1, &uiState.sudokuSel)
	case .RIGHT:
		selection_move(0, 1, &uiState.sudokuSel)
	case .UP:
		selection_move(-1, 0, &uiState.sudokuSel)
	case .DOWN:
		selection_move(1, 0, &uiState.sudokuSel)
	}
}

selection_set_group :: proc(
	grp: SudokuPuzzle.SelectionGroup,
	using selection: ^SudokuPuzzle.Selection,
) {
	if group != grp {
		group = grp
	} else {
		group = .None
	}
}

selection_move :: proc(#any_int rows, cols: int, using selection: ^SudokuPuzzle.Selection) {
	coords.row = u8(int(coords.row + 10) + rows % 10) % 10

	coords.col = u8(int(coords.col + 10) + cols % 10) % 10

	if rows != 0 && coords.row < 9 && coords.col > 8 do coords.col = 0
	if cols != 0 && coords.col < 9 && coords.row > 8 do coords.row = 0
}

selection_goto :: proc(#any_int num: u8, using uiState: ^UIState) {
	using sudokuSel
	if num == 0 {
		group = .None
		coords = {
			row = 9,
			col = 9,
		}
	} else {
		index := num - 1
		switch group {
		case .Row:
			coords.row = index
			if coords.col == 9 do coords.col = 0
		case .Col:
			coords.col = index
			if coords.row == 9 do coords.row = 0
		case .Sqr, .None:
			if inputMode == .jump {
				selection_move((2 - int(index) / 3) - 1, (int(index) % 3) - 1, &sudokuSel)
			} else {
				coords.row = (2 - index / 3) * 3 + 1
				coords.col = (index % 3) * 3 + 1
			}
		}
	}
}
