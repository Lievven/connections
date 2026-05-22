class_name CarBody
extends CharacterBody3D


@export var acceleration: float = 5.0

var steering: float = 0.0



func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	#velocity *= 1 - (0.2 * delta)
	velocity -= velocity.normalized() * delta
	move_and_slide()
	velocity = get_real_velocity()


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT):
		steering -= 20 * delta
	if Input.is_key_pressed(KEY_RIGHT):
		steering += 20 * delta
	clampf(steering, -20, 20)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accelerate") and is_on_floor():
		velocity += acceleration * global_transform.basis.z
