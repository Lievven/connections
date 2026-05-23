class_name RadioInterface
extends Node3D


var changing_volume: bool = false
var volume: float = 1
var current_time: float = 0



func _process(delta: float) -> void:
	current_time += delta
	var seconds = current_time
	var minutes = floori(seconds / 60)
	var centis = floori(seconds * 100)
	seconds = floori(seconds)
	centis -= seconds * 100
	seconds %= 60
	$Label3D.text = "%02d:%02d:%02d" % [minutes, seconds, centis]


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		changing_volume = false
	if not changing_volume:
		return
	if event is InputEventMouseMotion:
		var change = event.screen_relative.x / get_viewport().get_window().size.x
		volume += change
		volume = clampf(volume, 0, 1)
		print("Volume: ", volume, " - ", change)


func _on_volume_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			changing_volume = true


func _on_button_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int, source: CollisionObject3D) -> void:
	if not (event is InputEventMouseButton and event.is_pressed()):
		return
	
	if source == $Button1:
		switch_channel(1)
	if source == $Button2:
		switch_channel(2)
	if source == $Button3:
		switch_channel(3)
	if source == $Button4:
		switch_channel(4)

func switch_channel(channel_idx: int):
	print("Channel ", channel_idx)
