package SudokuGame

import "../SudokuFile"
import "../SudokuPuzzle"

GameStateFlags :: enum {
	preinit,
	quitting,
	start_new,
}

GameStateFlags_set :: bit_set[GameStateFlags]

GameState :: struct {
	workspace:      SudokuPuzzle.Workspace,
	uiState:        UIState,
	controlFlags:   GameStateFlags_set,
	puzzleStack:    [dynamic]SudokuPuzzle.Puzzle,
	selectedPuzzle: int,
}

UserAction :: struct {
	value:  SudokuPuzzle.Cell,
	action: UserActions,
}

UserActions :: enum {
	None,
	Action_MenuBtn,
	Action_MouseBtn,
	Action_Toggle,
}

game_init :: proc(gameState: ^GameState) {
	init_ui(gameState)
	return
}

run_game_loop :: proc(using gameState: ^GameState) {
	userAction := game_handle_input(&gameState.uiState)
	switch userAction.action {
	case {}:
	case .Action_MenuBtn:
		btn_on_click(gameState)
	case .Action_MouseBtn:
		if uiState.menuState.mouseOverBtn != {} {
			btn_on_click(gameState, uiState.menuState.mouseOverBtn)
		}
	case .Action_Toggle:
	}

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
		uiState.inputMode = .normal
		uiState.sudokuSel.group = .None
		uiState.sudokuSel.coords = {
			row = 9,
			col = 9,
		}
		inc_puzzle_selection(gameState)
	case:
	}
}

cleanup_game_loop :: proc(using GameState: ^GameState) {
	uiState.menuState.mouseOverBtn = {}
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
