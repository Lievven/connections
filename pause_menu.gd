class_name PauseMenu
extends Control

@export var phone_menu: PhoneMenu
@export var switch_menu_time: float = 0.5

@onready var start_menu_position = $StartMenu.position
@onready var pause_menu_position = $PauseMenu.position
@onready var game_over_menu_position = $GameOverMenu.position
@onready var controls_menu_position = $ControlsMenu.position

var current_menu = Menu.START
var previous_menu = Menu.START
var menu_offset = Vector2(0, 0)
enum Menu {START, PAUSE, GAME_OVER, CONTROLS}
var menu_tween: Tween


func switch_menu(new_menu: Menu):
	if menu_tween:
		menu_tween.kill()
	menu_tween = create_tween()
	menu_tween.bind_node(self)
	menu_tween.set_trans(Tween.TRANS_CUBIC)
	
	var new_offset: Vector2 = Vector2(0, 0)
	
	if new_menu == Menu.START:
		new_offset -= start_menu_position
	elif new_menu == Menu.PAUSE:
		new_offset -= pause_menu_position
	elif new_menu == Menu.GAME_OVER:
		new_offset -= game_over_menu_position
	elif new_menu == Menu.CONTROLS:
		if current_menu == Menu.START:
			new_offset -= start_menu_position
		elif current_menu == Menu.PAUSE:
			new_offset -= pause_menu_position
		elif current_menu == Menu.GAME_OVER:
			new_offset -= game_over_menu_position
		new_offset.y -= controls_menu_position.y
	
	previous_menu = current_menu
	current_menu = new_menu
	menu_tween.tween_property(self, "menu_offset", new_offset, switch_menu_time)


func _process(delta: float) -> void:
	$StartMenu.position = start_menu_position + menu_offset
	$GameOverMenu.position = game_over_menu_position + menu_offset
	$PauseMenu.position = pause_menu_position + menu_offset
	$ControlsMenu.position.y = controls_menu_position.y + menu_offset.y


func _input(event: InputEvent) -> void:
	pass


func _continue_game() -> void:
	phone_menu.deactivate_menu()


func _switch_to_keybinds() -> void:
	print("SWITCH TO KEYBINDS")
	switch_menu(Menu.CONTROLS)


func _surrender_run() -> void:
	print("SURRENDER RUN")
	switch_menu(Menu.GAME_OVER)
	connection_manager.surrender_run.emit()


func _start_new_game() -> void:
	print("START NEW GAME")
	switch_menu(Menu.PAUSE)


func _load_replay() -> void:
	print("LOAD REPLAY")


func _start_replay() -> void:
	print("START REPLAY")
	connection_manager.start_replay.emit()
	phone_menu.deactivate_menu()


func _copy_replay() -> void:
	print("COPY REPLAY")


func _return_to_main_menu() -> void:
	print("RETURN TO MAIN MENU")
	switch_menu(Menu.START)


func switch_to_previous() -> void:
	print("SWITCH TO PREVIOUS MENU")
	switch_menu(previous_menu)
