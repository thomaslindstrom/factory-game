@tool
@icon("res://modules/state/icons/cog-fallback.svg")
## State that activates itself if no other local state is active.
class_name StateFallback
extends State

func _init() -> void:
	validations_per_second = 0.0

func _validate_property(property: Dictionary) -> void:
	if property.name == &"validations_per_second":
		property.usage |= PROPERTY_USAGE_READ_ONLY

var parent_state_list: StateList
func try_activate() -> void:
	if not parent_state_list or not parent_state_list.is_active or parent_state_list.is_deactivating or parent_state_list.active_state: return
	activate()

func prepare() -> void:
	if not parent_state_list: return

	parent_state_list.on_activated.connect(func() -> void:
		try_activate.call_deferred()
	)

	for local_state in parent_state_list.local_states:
		local_state.on_deactivated.connect(func(_can_reactivate: bool) -> void:
			try_activate.call_deferred()
		)

	try_activate.call_deferred()

func _ready() -> void:
	super._ready()
	var parent: State = get_parent()

	if not parent is StateList:
		push_warning("`StateFallback` must be a child of a `StateList` node.")
		return

	if parent is StateSequence:
		push_error("`StateFallback` cannot be a child of a `StateSequence` node.")
		return

	parent_state_list = parent
	parent_state_list.on_ready.connect(func() -> void:
		prepare.call_deferred()
	)
