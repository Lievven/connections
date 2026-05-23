class_name Checkpoint
extends Area3D

@export var next_checkpoint: Checkpoint
@export var is_active = false


func _ready()-> void:
	visible = false
	if is_active:
		activate_checkpoint()


func activate_checkpoint():
	is_active = true
	visible = true
	var arrow_hover = get_tree().create_tween()
	arrow_hover.set_ease(Tween.EASE_IN_OUT)
	arrow_hover.set_trans(Tween.TRANS_QUAD)
	arrow_hover.tween_property($Arrow, "position", Vector3(0, 5, 0), 1.2)
	arrow_hover.tween_property($Arrow, "position", Vector3(0, 0, 0), 1.2)
	arrow_hover.set_loops()
	arrow_hover.bind_node(self)


func _on_body_entered(body: Node3D) -> void:
	if not is_active:
		return
	
	if next_checkpoint:
		next_checkpoint.activate_checkpoint()
		queue_free()
	
	print("WE HAVE A WINNER")
