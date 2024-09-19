package SudokuGame

import "../SudokuPuzzle"

MenuState :: struct {
	menuList: [dynamic]^Menu,
	current:  ^Menu,
	top:      ^Menu,
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

subMenu_click :: proc(subMenu: ^Menu, gameState: ^GameState) {
	subMenu.superMenu = gameState.uiState.menuState.current
	gameState.uiState.menuState.current = subMenu
}
