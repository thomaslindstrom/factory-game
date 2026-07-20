@tool
extends StateBehavior
## Behavior that immediately activates a given state, and deactivates itself.
class_name StateBehaviorSkip

@export var next_state: State

func enter() -> void:
	next_state.activate()
	state.deactivate()
