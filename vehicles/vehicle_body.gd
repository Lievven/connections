class_name PlayerVehicle
extends VehicleBody3D

@export var max_steer: float = 35
@export var steering_wheel: Node3D
@export var motor_force: float = 40.0
@export var motor_decay: float = 2
@export var press_per_second: float = 8

var current_rotation = 0

var forwards_speed = 0
var backwards_speed = 0
var timer = 3

var forwards_mode = false
var backwards_mode = false


@onready var start_transform: Transform3D


func _ready() -> void:
	start_transform = global_transform
	connection_manager.start_new_run.connect(reset_position)


func reset_position():
	angular_velocity = Vector3(0, 0, 0)
	linear_velocity = Vector3(0, 0, 0)
	global_transform = start_transform


func _process(delta: float) -> void:
	var steer_input: float = 0.5
	
	if connection_manager.is_using_mouse:
		var mouse_position = get_viewport().get_mouse_position().x
		var screen_width = get_viewport().get_visible_rect().size.x
	
		mouse_position = clampf(mouse_position, 0, screen_width)
		steer_input = 1 - mouse_position / screen_width
	else:
		steer_input -= Input.get_action_strength("right") / 2
		steer_input += Input.get_action_strength("left") / 2
	
	if connection_manager.is_steering_inverted:
		steer_input = 1 - steer_input
	
	if not freeze:
		steering = deg_to_rad(-max_steer + 2 * max_steer * steer_input)
	
	if steering_wheel:
		# Important to normalize, otherwise accumulated rounding errors lead to bugs.
		steering_wheel.global_basis = steering_wheel.global_basis.orthonormalized()
		steering_wheel.global_rotate(steering_wheel.global_basis.y, (steering - current_rotation) * 3)
		current_rotation = steering
	else:
		var z_rotation = global_rotation_degrees.z
		apply_torque(Vector3(0, 0, clampf(-z_rotation, -10, 10) * 40))
	
	var drop = delta * motor_force / motor_decay
	drop = min(drop, abs(engine_force))
	engine_force -= sign(engine_force) * drop
	#test_drive(delta)
	
	connection_manager.player_position = global_position


func test_drive(delta: float):
	timer -= delta
	if forwards_mode:
		forwards_speed = max(forwards_speed, linear_velocity.length())
	if backwards_mode:
		backwards_speed = max(backwards_speed, linear_velocity.length())
	if timer > 0:
		return
	engine_force = 0
	if forwards_mode:
		forwards_mode = false
		print("Forwards Speed: ", forwards_speed)
	if backwards_mode:
		backwards_mode = false
		print("Backwards Speed: ", backwards_speed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accelerate"):
		engine_force += (motor_force * 1.5 - engine_force) * 2 / motor_decay / press_per_second
		engine_force = clamp(engine_force, -motor_force, motor_force)
	if event.is_action_pressed("brake"):
		engine_force -= (motor_force * 1.5 - engine_force) * 2 / motor_decay / press_per_second
		engine_force = clamp(engine_force, -motor_force, motor_force)
