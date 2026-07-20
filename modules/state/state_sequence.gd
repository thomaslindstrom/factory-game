@tool
@icon("res://modules/state/icons/cog-sequence.svg")
## Activates the next local state when the previous local state is deactivated.
class_name StateSequence
extends StateList

func _init() -> void:
	single_active_state = true

func _validate_property(property: Dictionary) -> void:
	if property.name == &"single_active_state":
		property.usage |= PROPERTY_USAGE_READ_ONLY

func prepare_local_states() -> void:
	var local_states_size: int = local_states.size()
	active_state_index = -1
	
	for index in range(local_states_size):
		var local_state_index: int = index
		var local_state: State = local_states[local_state_index]

		if local_state.is_active:
			if index == 0 and is_active and not is_deactivating:
				active_state = local_state
				active_state_index = local_state_index
			else: local_state.deactivate()

		local_state.on_activated.connect(func() -> void:
			var previous_state: State = active_state
			active_state = local_state
			active_state_index = local_state_index
			
			if previous_state: previous_state.deactivate()
		)

		local_state.on_deactivated.connect(func(_can_reactivate: bool) -> void:
			if is_deactivating or not is_active: return
			if active_state and active_state != local_state: return

			active_state_index = local_state_index + 1
			var next_state: State = get_local_state_at(active_state_index)

			if next_state: next_state.activate()
			else: deactivate()
		)
