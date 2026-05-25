class_name PhoneMenu
extends MeshInstance3D


@export var inactive_target: Node3D
@export var activation_duration: float = 0.5

var active_position: Vector3
var active_basis: Basis

var activation_tween: Tween


func _ready() -> void:
	active_position = position
	active_basis = basis
	activate_menu()
	get_tree().paused = false
	connection_manager.win_run.connect(activate_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			deactivate_menu()
		else:
			activate_menu()


func deactivate_menu():
	connection_manager.is_menu_active = false
	
	if activation_tween:
		activation_tween.kill()
	activation_tween = create_tween()
	activation_tween.bind_node(self)
	activation_tween.finished.connect(has_deactivated)
	activation_tween.set_ease(Tween.EASE_IN_OUT)
	activation_tween.set_trans(Tween.TRANS_CIRC)
	
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
	activation_tween.finished.connect(has_activated)
	activation_tween.set_ease(Tween.EASE_IN_OUT)
	activation_tween.set_trans(Tween.TRANS_CIRC)
	
	activation_tween.tween_property(self, "position", active_position, activation_duration)
	activation_tween.parallel()
	activation_tween.tween_property(self, "basis", active_basis, activation_duration)


func has_activated():
	connection_manager.is_menu_active = true
	

func has_deactivated():
	visible = false
	get_tree().paused = false
