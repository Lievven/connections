class_name ChoicePath
extends Path3D

@export var traffic_light: TrafficLight
@export var connections: Array[ChoicePath]
@export var bake_interval: float = 3.0
@export var max_bikes = 0

var registered_bikes: Array[CharacterBike] = []

# DEPRECATED
var entry_points: Array[int]


func _ready() -> void:
	curve.bake_interval = bake_interval


func is_occupied() -> bool:
	return max_bikes > 0 and registered_bikes.size() >= max_bikes
	

func unregister_bike(bike: CharacterBike):
	registered_bikes.erase(bike)


func register_bike(new_bike: CharacterBike) -> CharacterBike:
	var closest_before: CharacterBike = null
	var progress_before = INF
	var closest_after: CharacterBike = null
	var progress_after = INF
	
	for b: CharacterBike in registered_bikes:
		if b.get_progress() > new_bike.get_progress():
			if b.get_progress() < progress_before:
				progress_before = b.get_progress()
				closest_before = b
		elif b.get_progress() < progress_after:
			progress_after = b.get_progress()
			closest_after = b
	
	registered_bikes.append(new_bike)
	
	if closest_after:
		closest_after.set_following_bike(new_bike)
	if closest_before:
		return closest_before
	return null


func stop_bike(target_point: Vector3) -> bool:
	if connections.size() == 0:
		return false
	if get_random_path():
		return false
	
	
	var last_point = curve.get_point_position(curve.point_count - 1)
	last_point *= global_basis.inverse()
	last_point += global_position
	last_point.y = target_point.y
	
	return target_point.distance_squared_to(last_point) < 200


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


# DEPRECATED
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
