@tool
extends StateFallback

@export var next_state: State
@export var area: Area2D

func handle_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(&"primary"):
		next_state.activate()

func enter() -> void:
	super.enter()
	area.input_event.connect(handle_input)

func exit() -> void:
	super.exit()
	area.input_event.disconnect(handle_input)
