class_name BikeSpawner
extends Area3D

@export var entry_path: ChoicePath
@export var bike_scene: PackedScene
@export var spawn_cooldown: float = 1

var spawn_timer = 0


func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0:
		return
	if not has_overlapping_bodies():
		spawn_bike()
		spawn_timer = spawn_cooldown


func spawn_bike():
	var bike = bike_scene.instantiate()
	if bike is CharacterBike:
		bike.target_path = entry_path
		add_child(bike)
