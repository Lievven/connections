class_name ChoicePath
extends Path3D

@export var connections: Array[ChoicePath]
@export var entry_points: Array[int]
@export var bake_interval: float = 3.0

func _ready() -> void:
	curve.bake_interval = bake_interval


func get_random_path() -> ChoicePath:
	if connections.is_empty():
		return null
	var index = randi_range(0, connections.size() - 1)
	return connections[index]


func get_closest_entry(point: Vector3) -> int:
	var closest_entry = null
	var entry_distance = INF
	
	for entry_index in entry_points:
		var entry_point = curve.get_point_position(entry_index)
		var distance = point.distance_squared_to(entry_point)
		if distance < entry_distance:
			closest_entry = entry_point
			entry_distance = distance
	
	return curve.get_baked_points().find(closest_entry)
