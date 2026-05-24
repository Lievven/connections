class_name KeyPressInterceptor
extends Control

var interceptor: Node = null


func _ready() -> void:
	visible = false


func intercept_event(intercepted_by: Node):
	visible = true
	interceptor = intercepted_by


func intercept_finished():
	visible = false
	interceptor = null


func _input(event: InputEvent) -> void:
	if not visible or not interceptor:
		return
	accept_event()
	if event.is_pressed() and interceptor.has_method("relay_input"):
		interceptor.relay_input(event)
