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
ControlProc :: proc(gameState: ^GameState)

@(private)
controlMap := map[rl.KeyboardKey]ControlProc {
	.SPACE = control_space,
	.ENTER = control_enter,
	.R     = control_R,
	.C     = control_C,
	.S     = control_S,
	.LEFT  = control_left,
	.RIGHT = control_right,
	.UP    = control_up,
	.DOWN  = control_down,
	.ZERO  = control_zero,
	.ONE   = control_one,
	.TWO   = control_two,
	.THREE = control_three,
	.FOUR  = control_four,
	.FIVE  = control_five,
	.SIX   = control_six,
	.SEVEN = control_seven,
	.EIGHT = control_eight,
	.NINE  = control_nine,
}

game_handle_input :: proc(gameState: ^GameState) {
	using gameState.uiState
	if key := rl.GetKeyPressed(); key != .KEY_NULL {
		if key != .ONE &&
		   key != .TWO &&
		   key != .THREE &&
		   key != .FOUR &&
		   key != .FIVE &&
		   key != .SIX &&
		   key != .SEVEN &&
		   key != .EIGHT &&
		   key != .NINE {
			switch inputMode {
			case .jump:
				inputMode = .normal
				sudokuSel.group = .None
			case .modify:
				inputMode = .normal
			case .normal:
				if controlProc := controlMap[key]; controlProc != {} do controlProc(gameState)
			}
		} else {
			if controlProc := controlMap[key]; controlProc != {} do controlProc(gameState)
		}
	}
}

control_R :: proc(gameState: ^GameState) {
	using gameState.uiState.sudokuSel
	if group != .Row {
		group = .Row
	} else {
		group = .None
	}
}
control_C :: proc(gameState: ^GameState) {
	using gameState.uiState.sudokuSel
	if group != .Col {
		group = .Col
	} else {
		group = .None
	}
}
control_S :: proc(gameState: ^GameState) {
	using gameState.uiState.sudokuSel
	if group != .Sqr {
		group = .Sqr
	} else {
		group = .None
	}
}

control_space :: proc(gameState: ^GameState) {
	using gameState.uiState

	#partial switch inputMode {
	case .normal:
		inputMode = .jump
		sudokuSel.group = .None
	case .jump:
		inputMode = .normal
		sudokuSel.group = .None
	}
}

control_enter :: proc(gameState: ^GameState) {
	using gameState.uiState

	#partial switch inputMode {
	case .normal:
		inputMode = .modify
	case .modify:
		inputMode = .normal
	}
}

control_left :: proc(gameState: ^GameState) {
	selection_move(0, -1, gameState)
}
control_right :: proc(gameState: ^GameState) {
	selection_move(0, 1, gameState)
}
control_up :: proc(gameState: ^GameState) {
	selection_move(-1, 0, gameState)
}
control_down :: proc(gameState: ^GameState) {
	selection_move(1, 0, gameState)
}

selection_move :: proc(#any_int rows, cols: int, gameState: ^GameState) {
	using gameState.uiState.sudokuSel

	coords.row = u8(int(coords.row + 10) + rows % 10) % 10

	coords.col = u8(int(coords.col + 10) + cols % 10) % 10

	if rows != 0 && coords.row < 9 && coords.col > 8 do coords.col = 0
	if cols != 0 && coords.col < 9 && coords.row > 8 do coords.row = 0
}

control_zero :: proc(gameState: ^GameState) {
	using gameState.uiState.sudokuSel
	group = .None
	coords = {
		row = 9,
		col = 9,
	}
}
control_one :: proc(gameState: ^GameState) {
	control_number_handler(0, gameState)
}
control_two :: proc(gameState: ^GameState) {
	control_number_handler(1, gameState)
}
control_three :: proc(gameState: ^GameState) {
	control_number_handler(2, gameState)
}
control_four :: proc(gameState: ^GameState) {
	control_number_handler(3, gameState)
}
control_five :: proc(gameState: ^GameState) {
	control_number_handler(4, gameState)
}
control_six :: proc(gameState: ^GameState) {
	control_number_handler(5, gameState)
}
control_seven :: proc(gameState: ^GameState) {
	control_number_handler(6, gameState)
}
control_eight :: proc(gameState: ^GameState) {
	control_number_handler(7, gameState)
}
control_nine :: proc(gameState: ^GameState) {
	control_number_handler(8, gameState)
}

control_number_handler :: proc(#any_int index: u8, gameState: ^GameState) {
	using gameState.uiState
	switch inputMode {
	case .normal:
		selection_goto_group(index, gameState)
	case .jump:
		selection_jump(index, gameState)
	case .modify:
		selection_modify(index, gameState)
	case:
	}
}

selection_goto_group :: proc(#any_int index: u8, gameState: ^GameState) {
	using gameState.uiState.sudokuSel

	switch group {
	case .Row:
		coords.row = index
		if coords.col == 9 do coords.col = 0
	case .Col:
		coords.col = index
		if coords.row == 9 do coords.row = 0
	case .Sqr:
		coords.row = (2 - index / 3) * 3 + 1
		coords.col = (index % 3) * 3 + 1
	case .None:
		coords.row = (2 - index / 3) * 3 + 1
		coords.col = (index % 3) * 3 + 1
		group = .Sqr
		gameState.uiState.inputMode = .jump
	}
}

selection_jump :: proc(#any_int index: u8, gameState: ^GameState) {
	using gameState.uiState.sudokuSel
	#partial switch group {
	case .None:
		coords.row = (2 - index / 3) * 3 + 1
		coords.col = (index % 3) * 3 + 1
		group = .Sqr
	case .Sqr:
		gameState.uiState.inputMode = .normal
		group = .None
		selection_move((2 - int(index) / 3) - 1, (int(index) % 3) - 1, gameState)
	case:
		gameState.uiState.inputMode = .normal
	}
}


selection_modify :: proc(#any_int index: int, gameState: ^GameState) {
	using gameState.uiState
	SudokuPuzzle.toggle_possible(
		&sudokuSel,
		SudokuPuzzle.CellPossibilities{index + 1},
		&gameState.workspace,
	)
}
