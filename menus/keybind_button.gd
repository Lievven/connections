class_name KeybindButton
extends Button

@export var linked_action: String
@export var event_index: int = 0

var linked_event: InputEvent

var awaiting_input = false

func _ready() -> void:
	var events = InputMap.action_get_events(linked_action)
	if events.size() <= event_index:
		return
	linked_event = events[event_index]
	text = linked_event.as_text().split("-")[0]


func relay_input(event: InputEvent) -> void:
	if not awaiting_input or not event.is_pressed():
		return
	awaiting_input = false
	key_press_interceptor.intercept_finished()
	
	text = event.as_text()
	if linked_event:
		InputMap.action_erase_event(linked_action, linked_event)
	linked_event = event
	InputMap.action_add_event(linked_action, linked_event)


func await_assign_key():
	awaiting_input = true
	key_press_interceptor.intercept_event(self)
