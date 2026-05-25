class_name BikeSpawner
extends Area3D

@export var entry_path: ChoicePath
@export var bike_scene: PackedScene
@export var min_cooldown: float = 0.5
@export var max_cooldown: float = 3

var spawn_timer = 0


func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0:
		return
	if not has_overlapping_bodies():
		spawn_bike()
		var increment = randf_range(min_cooldown, max_cooldown)
		increment *= randf_range(min_cooldown, max_cooldown)
		increment = sqrt(increment)
		spawn_timer = increment


func spawn_bike():
	var bike = bike_scene.instantiate()
	if bike is CharacterBike:
		bike.target_path = entry_path
		add_child(bike)
