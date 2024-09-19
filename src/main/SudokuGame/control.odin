package SudokuGame

import "../SudokuPuzzle"
import "core:fmt"
import rl "vendor:raylib"

SudokuSelectionGroup :: enum {
	None,
	Row,
	Col,
	Sqr,
}

SudokuSelection :: struct {
	coords: SudokuPuzzle.CellCoords,
	group:  SudokuSelectionGroup,
}

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
	sudokuSel:       SudokuSelection,
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
	if key := rl.GetKeyPressed(); key != rl.KeyboardKey.KEY_NULL {
		if gameState.uiState.inputMode == .jump &&
		   key != .ONE &&
		   key != .TWO &&
		   key != .THREE &&
		   key != .FOUR &&
		   key != .FIVE &&
		   key != .SIX &&
		   key != .SEVEN &&
		   key != .EIGHT &&
		   key != .NINE {
			gameState.uiState.inputMode = .normal
			gameState.uiState.sudokuSel.group = .None
		}

		if controlProc := controlMap[key]; controlProc != {} do controlProc(gameState)
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
	selection_goto_group(0, gameState)
}
control_two :: proc(gameState: ^GameState) {
	selection_goto_group(1, gameState)
}
control_three :: proc(gameState: ^GameState) {
	selection_goto_group(2, gameState)
}
control_four :: proc(gameState: ^GameState) {
	selection_goto_group(3, gameState)
}
control_five :: proc(gameState: ^GameState) {
	selection_goto_group(4, gameState)
}
control_six :: proc(gameState: ^GameState) {
	selection_goto_group(5, gameState)
}
control_seven :: proc(gameState: ^GameState) {
	selection_goto_group(6, gameState)
}
control_eight :: proc(gameState: ^GameState) {
	selection_goto_group(7, gameState)
}
control_nine :: proc(gameState: ^GameState) {
	selection_goto_group(8, gameState)
}

selection_goto_group :: proc(#any_int index: u8, gameState: ^GameState) {
	using gameState.uiState.sudokuSel

	#partial switch gameState.uiState.inputMode {
	case .normal:
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
	case .jump:
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
}
