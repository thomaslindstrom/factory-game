@tool
@icon("res://modules/state/icons/cog-list.svg")
class_name StateList
extends State

## If `true`, only one local state child can be active at a time. If a state is active, and another state becomes active, the previous state will be deactivated.
@export var single_active_state: bool = true

var states: Array[State] = []
var local_states: Array[State] = []

func find_states(children: Array[Node]) -> Array[State]:
	var found_states: Array[State] = []

	for child in children:
		if not child is State: continue
		var state_children: Array[Node] = child.get_children()
		
		if not state_children.is_empty():
			found_states.append_array(find_states(state_children))

		found_states.append(child)
	return found_states

func find_local_states(children: Array[Node]) -> Array[State]:
	var found_states: Array[State] = []
	
	for child in children:
		if not child is State: continue
		found_states.append(child)
	return found_states

func get_local_state_at(index: int) -> State:
	if index < 0 or index >= local_states.size(): return null
	return local_states[index]

var active_state: State
var active_state_index: int = -1

func get_null_state_index() -> int:
	return local_states.size() + 1

func prepare_local_states() -> void:
	if not single_active_state: return

	var local_states_size: int = local_states.size()
	var null_state_index: int = get_null_state_index()
	active_state_index = null_state_index
	
	for index in range(local_states_size):
		var local_state_index: int = index
		var local_state: State = local_states[local_state_index]

		if local_state.is_active:
			if active_state: local_state.deactivate()
			elif is_active:
				active_state = local_state
				active_state_index = local_state_index

		local_state.on_activated.connect(func() -> void:
			if active_state: active_state.deactivate()
			active_state = local_state
			active_state_index = local_state_index
		)

		local_state.on_deactivated.connect(func(_can_reactivate: bool) -> void:
			if active_state and active_state == local_state:
				active_state = null
				active_state_index = null_state_index
		)

func _ready() -> void:
	super._ready()
	
	var children: Array[Node] = get_children()

	states.clear()
	states.append_array(find_states(children))

	local_states.clear()
	local_states.append_array(find_local_states(children))

	prepare_local_states()

## `true` when the state is in the process of deactivating itself.
var is_deactivating: bool = false
func deactivate(state_can_reactivate: bool = true) -> void:
	is_deactivating = true

	for local_state in local_states: 
		local_state.deactivate(state_can_reactivate)
	
	super.deactivate(state_can_reactivate)
	is_deactivating = false

func exit() -> void:
	super.exit()
	active_state = null
	active_state_index = get_null_state_index()

func render_process(delta: float) -> void:
	super.render_process(delta)
	
	for local_state in local_states:
		if not local_state.is_active: continue
		local_state.render_process(delta)

func physics_process(delta: float) -> void:
	super.physics_process(delta)

	for local_state in local_states:
		if not local_state.is_active: continue
		local_state.physics_process(delta)
