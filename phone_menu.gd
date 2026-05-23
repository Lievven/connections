class_name PhoneMenu
extends MeshInstance3D


@export var inactive_target: Node3D
@export var activation_duration: float = 0.3

var active_position: Vector3
var active_basis: Basis

var activation_tween: Tween


func _ready() -> void:
	active_position = position
	active_basis = basis


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_home"):
		print("Activate")
		if visible:
			deactivate_menu()
		else:
			activate_menu()


func deactivate_menu():
	if activation_tween:
		activation_tween.kill()
	activation_tween = create_tween()
	activation_tween.bind_node(self)
	activation_tween.finished.connect(has_deactivated)
	
	activation_tween.tween_property(self, "position", inactive_target.position, activation_duration)
	activation_tween.parallel()
	activation_tween.tween_property(self, "basis", inactive_target.basis, activation_duration)


func activate_menu():
	visible = true
	get_tree().paused = true
	
	if activation_tween:
		activation_tween.kill()
	activation_tween = create_tween()
	activation_tween.bind_node(self)
	
	activation_tween.tween_property(self, "position", active_position, activation_duration)
	activation_tween.parallel()
	activation_tween.tween_property(self, "basis", active_basis, activation_duration)


func has_deactivated():
	visible = false
	get_tree().paused = false
