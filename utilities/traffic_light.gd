class_name TrafficLight
extends Node3D

enum StopLight {RED, YELLOW, GREEN}

@export var blocked_intersection: Area3D

@onready var red_material: StandardMaterial3D = $Red.get_surface_override_material(0)
@onready var yellow_material: StandardMaterial3D = $Yellow.get_surface_override_material(0)
@onready var green_material: StandardMaterial3D = $Green.get_surface_override_material(0)

var state: StopLight = StopLight.RED
var timer: float = 1



func _process(delta: float) -> void:
	timer -= delta
	if timer > 0:
		return
	
	if state == StopLight.RED:
		timer = 10
		change_state(StopLight.GREEN)
	elif state == StopLight.YELLOW:
		timer = 10
		change_state(StopLight.RED)
	elif state == StopLight.GREEN:
		timer = 3
		change_state(StopLight.YELLOW)


func change_state(new_state: StopLight):
	yellow_material.emission_enabled = false
	green_material.emission_enabled = false
	red_material.emission_enabled = false
	state = new_state
	if state == StopLight.RED:
		red_material.emission_enabled = true
	if state == StopLight.YELLOW:
		yellow_material.emission_enabled = true
	if state == StopLight.GREEN:
		green_material.emission_enabled = true
		
		
