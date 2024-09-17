package SudokuGame

import "../SudokuFile"
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

GameStateFlags :: enum {
	preinit,
	quitting,
	start_new,
}

GameStateFlags_set :: bit_set[GameStateFlags]

GameState :: struct {
	workspace:      SudokuPuzzle.SudokuWorkspace,
	uiState:        UIState,
	controlFlags:   GameStateFlags_set,
	puzzleStack:    [dynamic]SudokuPuzzle.Puzzle,
	selectedPuzzle: int,
}

game_init :: proc(gameState: ^GameState) {
	init_menu(gameState)
	return
}

run_game_loop :: proc(using gameState: ^GameState) {
	switch {
	case .quitting in controlFlags:
	case .start_new in controlFlags:
		if .preinit in controlFlags {
			set_puzzle_selection(gameState, 0)
			controlFlags -= {.preinit}
			uiState.menuState.top.buttons[0].text = "New"
		} else {
			inc_puzzle_selection(gameState)
		}
		controlFlags -= {.start_new}
	case .preinit in controlFlags:
		inc_puzzle_selection(gameState)
	case:
	}
	return
}

@(private)
inc_puzzle_selection :: proc(using gameState: ^GameState) {
	if selectedPuzzle >= len(puzzleStack) - 1 {
		selectedPuzzle = 0
	} else {
		selectedPuzzle += 1
	}
	SudokuPuzzle.set_workspace_Puzzle(&workspace, &puzzleStack[selectedPuzzle])
}

@(private)
set_puzzle_selection :: proc(using gameState: ^GameState, #any_int select: int) {
	if select < len(puzzleStack) && select >= 0 {
		selectedPuzzle = select
	} else {
		selectedPuzzle = 0
	}
	SudokuPuzzle.set_workspace_Puzzle(&workspace, &puzzleStack[selectedPuzzle])
}

game_quit :: proc(gameState: ^GameState) {
	gameState.controlFlags += {.quitting}
	return
}

game_start :: proc(gameState: ^GameState) {
	gameState.controlFlags += {.start_new}
	return
}
