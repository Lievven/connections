class_name DrivePath
extends Path3D

@export var player_vehicle: PlayerVehicle
@export var is_recording: bool = true
@export var recording_interval: float = 1.0

var timestamps: Array[float] = []
var angles: Array[Basis] = []
var steerings: Array[float] = []

var last_recording: Vector3
var last_timestamp: float = 0

var drive_tween: Tween
var replay_step: int = 0


func _ready() -> void:
	connection_manager.start_replay.connect(start_replay)
	connection_manager.import_replay.connect(import_drive_path)
	connection_manager.export_replay.connect(export_drive_path)
	connection_manager.surrender_run.connect(end_replay)


func _process(delta: float) -> void:
	if not is_recording:
		return
	
	var dist_squared = last_recording.distance_squared_to(player_vehicle.global_position)
	last_timestamp += delta
	if dist_squared >= pow(recording_interval, 2):
		add_recording_point()


func follow_drive_path():
	if drive_tween:
		drive_tween.kill()
	drive_tween = create_tween()
	drive_tween.bind_node(self)
	drive_tween.finished.connect(follow_drive_path)
	drive_tween.set_parallel(true)
	
	var step = timestamps[replay_step]
	
	drive_tween.tween_property(player_vehicle, \
		"global_position", \
		curve.get_point_position(replay_step), \
		step)
	
	drive_tween.tween_property(player_vehicle, \
		"global_basis", \
		angles[replay_step], \
		step)
	
	drive_tween.tween_property(player_vehicle, \
		"steering", \
		steerings[replay_step], \
		step)
	
	replay_step += 1
	replay_step %= angles.size()


func add_recording_point():
	curve.add_point(player_vehicle.global_position - self.global_position)
	last_recording = player_vehicle.global_position
	timestamps.append(last_timestamp)
	last_timestamp = 0
	angles.append(player_vehicle.global_basis)
	steerings.append(player_vehicle.steering)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		change_replay_mode()


func change_replay_mode():
	if is_recording:
		start_replay()
	else:
		end_replay()


func start_replay():
	visible = true
	is_recording = false
	player_vehicle.freeze = true
	$CSGPolygon3D.path_node = self.get_path()
	follow_drive_path()


func end_replay():
	if is_recording:
		return
	
	visible = false
	is_recording = true
	player_vehicle.freeze = false
	$CSGPolygon3D.path_node = ""
	drive_tween.kill()
	curve.clear_points()
	angles.clear()
	timestamps.clear()
	steerings.clear()
	last_timestamp = 0
	replay_step = 0


func import_drive_path():
	var json = JSON.new()
	var sanity_check = json.parse(DisplayServer.clipboard_get())
	if sanity_check != OK:
		print("INVALID JSON")
		return
	
	var dict = json.data
	
	timestamps.assign(dict["timestamps"])
	if not timestamps:
		print("NO VALID TIMESTAMPS")
		return
	var sample_count = timestamps.size()
	
	if not dict["bases"] or dict["bases"].size() != sample_count:
		print("NO VALID BASES")
		return
	angles = []
	angles.resize(sample_count)
	var i = 0
	for b in dict["bases"]:
		angles[i] = read_base(b)
		i+= 1
	
	steerings.assign(dict["steerings"])
	if not steerings or steerings.size() != sample_count:
		print("NO VALID STEERING")
		return
		
	var points = dict["points"]
	if not points or points.size() != sample_count:
		print("NO VALID POINTS")
		return
	curve.clear_points()
	for p in points:
		curve.add_point(read_vector(p))


func export_drive_path():
	print("EXPORT")
	var dict: Dictionary = {}
	var points: Array[Vector3] = []
	points.resize(curve.point_count)
	for i in curve.point_count:
		points[i] = curve.get_point_position(i)
		
	dict["points"] = points
	dict["timestamps"] = timestamps
	dict["bases"] = angles
	dict["steerings"] = steerings
	
	var path: String = JSON.stringify(dict)
	DisplayServer.clipboard_set(path)


func read_vector(stringified: String) -> Vector3:
	var num_strings = stringified.remove_chars("XYZ[()]:,").split(" ")
	return Vector3(num_strings[0].to_float(), num_strings[1].to_float(), num_strings[2].to_float())


func read_base(stringified: String) -> Basis:
	var new_base = Basis()
	var num_strings = stringified.remove_chars("XYZ[()]:,").split(" ")
	new_base.x = Vector3(num_strings[1].to_float(), num_strings[2].to_float(), num_strings[3].to_float())
	new_base.y = Vector3(num_strings[5].to_float(), num_strings[6].to_float(), num_strings[7].to_float())
	new_base.z = Vector3(num_strings[9].to_float(), num_strings[10].to_float(), num_strings[11].to_float())
	return new_base
