package SudokuGame

import "../SudokuPuzzle"

MenuState :: struct {
	menuList:     [dynamic]^Menu,
	current:      ^Menu,
	top:          ^Menu,
	mouseOverBtn: ^Button,
}

Menu :: struct {
	text:      string,
	selected:  u8,
	buttons:   [dynamic]Button,
	superMenu: ^Menu,
}

Button :: struct {
	text:     string,
	on_click: proc(gameState: ^GameState),
	subMenu:  ^Menu,
}

init_menu :: proc(gameState: ^GameState, allocator := context.allocator) {
	using gameState.uiState.menuState
	append(&menuList, new(Menu, allocator))

	top = menuList[0]
	current = top

	top^ = Menu {
		text     = "Menu",
		selected = 0,
		buttons  = make([dynamic]Button, allocator),
	}

	append(&top.buttons, Button{text = "Start", on_click = game_start})
	append(&top.buttons, Button{text = "Quit", on_click = game_quit})
}

btn_on_click :: proc(gameState: ^GameState, btn: ^Button = {}) {
	using gameState.uiState.menuState
	button: ^Button
	if btn == {} {
		button = &current.buttons[current.selected]
	} else {
		button = btn
	}
	if button.subMenu != {} {
		subMenu_click(&button.subMenu^, &gameState.uiState.menuState)
	} else {
		button.on_click(gameState)
	}
}

subMenu_click :: proc(subMenu: ^Menu, using menuState: ^MenuState) {
	subMenu.superMenu = current
	current = subMenu
}
