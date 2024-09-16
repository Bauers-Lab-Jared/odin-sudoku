package SudokuGame

import "../SudokuPuzzle"

RowNum :: distinct u8
ColNum :: distinct u8
SqrNum :: distinct u8
SudokuSelection :: union {
	SudokuPuzzle.CellCoords,
	RowNum,
	ColNum,
	SqrNum,
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

GameState :: struct {
	workspace: SudokuPuzzle.SudokuWorkspace,
	uiState:   UIState,
}

run_game_loop :: proc(gameState: ^GameState) {
	return
}

game_quit :: proc(gameState: ^GameState) {
	return
}

game_start :: proc(gameState: ^GameState) {
	return
}
