class_name CharacterBike
extends CharacterBody3D

@export var rotation_speed: float = 3.0
@export var max_speed: float = 10
@export var acceleration: float = 3
@export var target_path: ChoicePath
var speed: float = 0
var baked_curve: PackedVector3Array
var target_index: int = 0
var target_point: Vector3


func _ready() -> void:
	target_path.curve.bake_interval = target_path.bake_interval
	baked_curve = target_path.curve.get_baked_points()
	target_point = baked_curve.get(0) + target_path.global_position


func _process(delta: float) -> void:
	if $Area3D.has_overlapping_bodies() or target_path.stop_bike(global_position):
		speed -= acceleration * delta
	else:
		speed += acceleration * delta
	speed = clampf(speed, 0, max_speed)
	
	$Target.global_position = target_point
	var dist = target_point - global_position
	dist.y = 0
	if dist.length() > 0.5:
		return
		
	target_index += 1
	
	if target_index >= baked_curve.size():
		assign_new_path()
	if not target_path:
		return
	target_point = baked_curve.get(target_index) + target_path.global_position


func assign_new_path():
	target_path.enter_exit_bike(false)
	target_path = target_path.get_random_path()
	if not target_path:
		queue_free()
		return
	target_index = target_path.get_closest_entry(target_point)
	baked_curve = target_path.curve.get_baked_points()
	target_path.enter_exit_bike(true)


func _physics_process(delta: float) -> void:
	velocity = get_gravity()
	var target_direction = global_position.direction_to(target_point)
	target_direction.y = 0 # since bikes don't fly, we want to ignore the height
	var target_angle = basis.z.signed_angle_to(target_direction, Vector3.UP)
	rotate_y(rotation_speed * delta * clampf(target_angle, -1, 1))
	
	velocity += basis.z.normalized() * speed
	
	move_and_slide()


func _debug_input(delta: float):
	if Input.is_key_pressed(KEY_LEFT):
		rotate_y(3 * delta)
	if Input.is_key_pressed(KEY_RIGHT):
		rotate_y(-3 * delta)
	if Input.is_key_pressed(KEY_UP):
		velocity += basis.x * 5
	if Input.is_key_pressed(KEY_DOWN):
		velocity -= basis.x * 5
