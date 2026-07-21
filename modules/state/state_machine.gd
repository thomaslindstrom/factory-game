@tool
@icon("res://modules/state/icons/cogs.svg")
## Parent root class node required to set up a state machine. 
class_name StateMachine
extends StateList

func _init() -> void:
	validations_per_second = 0.0

func _validate_property(property: Dictionary) -> void:
	if property.name == &"validations_per_second":
		property.usage |= PROPERTY_USAGE_READ_ONLY

func get_active_states() -> Array[State]:
	var active_states: Array[State] = []
	for state in states: if state.is_active: active_states.append(state)
	return active_states

func get_active_states_names() -> String:
	var active_states: Array[State] = get_active_states()

	return ", ".join(
		active_states
			.filter(func(state: State) -> bool: return state.is_logged)
			.map(func(state: State) -> String: return state.name)
	)

func debug_print(...messages: Array[Variant]) -> void:
	if is_logged: 
		var parent_name: StringName = get_parent().name if get_parent() else &"root"
		messages.insert(0, "[" + parent_name + "/" + name + "]: ")
		print.callv(messages)

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	for state in states:
		state.machine = self
		state.initialize()

	initialize()
	activate()

	debug_print("Initialized with ", states.size(), " states.")

	for state in states:
		debug_print("- `", state.name, "`")

	for state in states:
		state.on_activated.connect(func() -> void:
			debug_print("Activated `", state.name, "`")
		)
		
		state.on_deactivated.connect(
			func(state_can_reactivate: bool) -> void:
				debug_print("Deactivated `", state.name, "`", " (can_reactivate: ", state_can_reactivate, ")")
		)

func _process(delta: float) -> void:
	if not is_active or Engine.is_editor_hint(): return
	for state in states: state.process(delta)
	render_process(delta)

func _physics_process(delta: float) -> void:
	if not is_active or Engine.is_editor_hint(): return
	physics_process(delta)
