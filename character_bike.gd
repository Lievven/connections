class_name CharacterBike
extends CharacterBody3D

@export var target_path: Path3D
var target_index = 0
var curve
var target


func _ready() -> void:
	target_path
	curve = target_path.curve.get_baked_points()
	target = curve[0]


func _process(delta: float) -> void:
	if not target:
		return
	var dist = target - position
	dist.y = 0
	if dist.length() < 1:
		target_index += 1
		print(target_index)
		if curve.size() > target_index:
			target = curve[target_index]
		else:
			target = null
		


func _physics_process(delta: float) -> void:
	velocity = get_gravity()
	if Input.is_key_pressed(KEY_LEFT):
		rotate_y(3 * delta)
	if Input.is_key_pressed(KEY_RIGHT):
		rotate_y(-3 * delta)
	if Input.is_key_pressed(KEY_UP):
		velocity += basis.x * 5
	if Input.is_key_pressed(KEY_DOWN):
		velocity -= basis.x * 5
	
	if target:
		var target_direction = global_position.direction_to(target)
		target_direction.y = 0
		var target_angle = Vector3(1, 0, 0).signed_angle_to(target_direction, Vector3.UP)
		target_angle = rotation.y - target_angle
		rotate_y(-3 * delta * clampf(target_angle, -1, 1))
		
		var target_horizontal = target - position
		target_horizontal.y = 0
		target_horizontal = target_horizontal.normalized()
		velocity += target_horizontal * 5
	
	if not Input.is_key_pressed(KEY_SPACE):
		move_and_slide()
