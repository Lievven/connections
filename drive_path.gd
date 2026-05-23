class_name DrivePath
extends Path3D

@export var player_vehicle: PlayerVehicle
@export var is_recording: bool = true
@export var recording_interval: float = 1.0

var timestamps: Array[float] = []
var angles: Array[Vector3] = []
var steerings: Array[float] = []

var last_recording: Vector3
var last_timestamp: float = 0

var drive_tween: Tween
var replay_step: int = 0


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
	
	drive_tween.tween_property(player_vehicle, \
		"global_position", \
		curve.get_point_position(replay_step), \
		timestamps[replay_step])
		
	drive_tween.tween_property(player_vehicle, \
		"rotation", \
		angles[replay_step], \
		timestamps[replay_step])
	
	drive_tween.tween_property(player_vehicle, \
		"steering", \
		steerings[replay_step], \
		timestamps[replay_step])
	
	replay_step += 1
	replay_step %= angles.size()
	print(timestamps[replay_step])


func add_recording_point():
		curve.add_point(player_vehicle.global_position - self.global_position)
		last_recording = player_vehicle.global_position
		timestamps.append(last_timestamp)
		last_timestamp = 0
		angles.append(player_vehicle.rotation)
		steerings.append(player_vehicle.steering)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		change_replay_mode()


func change_replay_mode():
	if is_recording:
		visible = true
		is_recording = false
		player_vehicle.freeze = true
		follow_drive_path()
	else:
		visible = false
		is_recording = true
		player_vehicle.freeze = false
		drive_tween.kill()
		curve.clear_points()
		angles.clear()
		timestamps.clear()
		steerings.clear()
		last_timestamp = 0
		replay_step = 0
		
		
