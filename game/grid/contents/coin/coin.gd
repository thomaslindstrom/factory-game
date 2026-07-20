@tool
extends GridItemContent

@export var active_state: State

func activate() -> bool:
	return active_state.activate()
