class_name CharacterBike
extends CharacterBody3D

@export var rotation_speed: float = 3.0
@export var max_speed: float = 10
@export var acceleration: float = 3
@export var target_path: ChoicePath
@export var follow_distance: float = 5
var speed: float = 0
var target_point: Vector3

var path_follow: PathFollow3D
var follows_bike: CharacterBike


func _ready() -> void:
	path_follow = PathFollow3D.new()
	follows_bike = target_path.register_bike(self)
	target_path.add_child(path_follow)


func _process(delta: float) -> void:
	var path_point = path_follow.global_position
	path_point.y = global_position.y
	if path_point.distance_squared_to(global_position) > 25:
		break_or_accelerate(delta)
		return
	
	var pre_progress = path_follow.progress
	path_follow.progress += 1
	if path_follow.progress < pre_progress:
		assign_new_path()
		
	if target_path:
		target_point = path_follow.global_position
		$Target.global_position = target_point
		break_or_accelerate(delta)


func break_or_accelerate(delta: float):
	var red_light = target_path.stop_bike(global_position)
	var distance_to_previous = INF
	if follows_bike:
		distance_to_previous = global_position.distance_to(follows_bike.global_position)
	if red_light or distance_to_previous < follow_distance:
		speed -= acceleration * delta
	else:
		speed += acceleration * delta
	speed = clampf(speed, 0, max_speed)
	


func assign_new_path():
	target_path.enter_exit_bike(false)
	target_path.remove_child(path_follow)
	target_path = target_path.get_random_path()
	if not target_path:
		queue_free()
		return
	target_path.add_child(path_follow)
	follows_bike = target_path.register_bike(self)
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
		velocity += basis.z * 5
	if Input.is_key_pressed(KEY_DOWN):
		velocity -= basis.z * 5
