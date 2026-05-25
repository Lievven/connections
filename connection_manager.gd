class_name ConnectionManager
extends Node

signal start_replay
signal surrender_run
signal start_new_run
signal win_run
signal export_replay
signal import_replay


var is_menu_active = false
var is_using_mouse = true
var is_steering_inverted = false

var game_timer: float = 0
