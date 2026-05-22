class_name ChoicePath
extends Path3D

@export var traffic_light: TrafficLight
@export var connections: Array[ChoicePath]
@export var entry_points: Array[int]
@export var bake_interval: float = 3.0
@export var max_bikes = 0

var bikes_inside = 0


func _ready() -> void:
	curve.bake_interval = bake_interval


func is_occupied() -> bool:
	return max_bikes > 0 and bikes_inside >= max_bikes


func stop_bike(target_point: Vector3) -> bool:
	if max_bikes <= 0:
		return false
	if get_random_path():
		return false
	
	var last_point = curve.get_point_position(curve.point_count - 1) + global_position
	return target_point.distance_squared_to(last_point) < 100


func enter_exit_bike(has_entered: bool):
	if not max_bikes:
		return
	if has_entered:
		bikes_inside += 1
	else:
		bikes_inside -= 1


func get_random_path() -> ChoicePath:
	if connections.is_empty():
		return null
	var index = randi_range(0, connections.size() - 1)
	var start_index = index
	while connections[index].is_connection_blocked():
		index += 1
		index %= connections.size()
		if index == start_index:
			return null
	return connections[index]


func get_forced_path() -> ChoicePath:
	for connection in connections:
		if connection.is_connection_forced():
			return connection
	return null


func is_connection_forced():
	if is_occupied() or not traffic_light:
		return false
	var player_in_intersection = false
	if traffic_light.blocked_intersection:
		player_in_intersection = traffic_light.blocked_intersection.has_overlapping_bodies()
	return traffic_light.state != TrafficLight.StopLight.RED and player_in_intersection


func is_connection_blocked() -> bool:
	if is_occupied():
		return true
	if not traffic_light:
		return false
	return traffic_light.state != TrafficLight.StopLight.RED


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
