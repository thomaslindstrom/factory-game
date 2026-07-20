@tool
@icon("res://modules/state/icons/cogs.svg")
## Parent root class node required to set up a state machine. 
class_name StateMachine
extends StateList

func _init() -> void:
	is_logged = false
	validations_per_second = 0.0

func _validate_property(property: Dictionary) -> void:
	if property.name == &"is_logged":
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == &"validations_per_second":
		property.usage |= PROPERTY_USAGE_READ_ONLY

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	for state in states:
		state.machine = self
		state.initialize()

	initialize()
	activate()

func _process(delta: float) -> void:
	if not is_active or Engine.is_editor_hint(): return
	for state in states: state.process(delta)
	render_process(delta)

func _physics_process(delta: float) -> void:
	if not is_active or Engine.is_editor_hint(): return
	physics_process(delta)
