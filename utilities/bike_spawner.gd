class_name BikeSpawner
extends Area3D

@export var entry_path: ChoicePath
@export var bike_scene: PackedScene
@export var min_cooldown: float = 0.5
@export var max_cooldown: float = 3
@export var min_spawn_range: float = 400
@export var max_spawn_range: float = 500

var spawn_timer = 0
var path_follow: PathFollow3D

func _ready() -> void:
	path_follow = PathFollow3D.new()
	entry_path.add_child.call_deferred(path_follow)


func _process(delta: float) -> void:
	path_follow.progress_ratio += delta / 2
	global_position = path_follow.global_position
	spawn_timer -= delta
	var player_distance = connection_manager.player_position.distance_squared_to(global_position)
	if player_distance < pow(min_spawn_range, 2) or player_distance > pow(max_spawn_range, 2):
		return
	
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
		bike.starting_progress = path_follow.progress
		get_tree().root.add_child(bike)
		bike.global_position = global_position + Vector3(0, 1, 0)
