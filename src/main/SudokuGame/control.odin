package SudokuGame

import "../SudokuPuzzle"
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

game_handle_input :: proc(gameState: ^GameState) {
	if key := rl.GetKeyPressed(); key != rl.KeyboardKey.KEY_NULL {
	}
}
