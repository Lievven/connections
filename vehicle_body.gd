extends VehicleBody3D

@export var max_steer: float = 35
@export var steering_wheel: Node3D
@export var motor_force: float = 40

var current_rotation = 0

var forwards_speed = 0
var backwards_speed = 0
var timer = 3

var forwards_mode = false
var backwards_mode = false


func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position().x
	var screen_width = get_viewport().get_visible_rect().size.x
	
	mouse_position = clampf(mouse_position, 0, screen_width)
	var steer_input = mouse_position / screen_width
	steering = deg_to_rad(-max_steer + 2 * max_steer * steer_input)
	
	if steering_wheel:
		# Important to normalize, otherwise accumulated rounding errors lead to bugs.
		steering_wheel.global_basis = steering_wheel.global_basis.orthonormalized()
		steering_wheel.global_rotate(steering_wheel.global_basis.y, (steering - current_rotation) * 3)
		current_rotation = steering
	else:
		var z_rotation = global_rotation_degrees.z
		apply_torque(Vector3(0, 0, clampf(-z_rotation, -10, 10) * 40))
	
	test_drive(delta)


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
		print(constant_force )
	if event.is_action_pressed("ui_up"):
		forwards_mode = true
		engine_force = motor_force
		timer = 3
	if event.is_action_pressed("ui_down"):
		backwards_mode = true
		engine_force = -motor_force
		timer = 3
