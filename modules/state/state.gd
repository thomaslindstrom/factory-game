@tool
@icon("res://modules/state/icons/cog.svg")
class_name State
extends Node

## If `true`, will print debug logging
@export var is_logged: bool = false

var validation_interval: float = 0.0
@export_range(0, 60, 1) var validations_per_second: float = 0.0:
	set(value):
		validations_per_second = value
		validation_interval = 1.0 / value if value > 0 else 0.0

## `true` when the state is active.
var is_active: bool = false
## If this state is one-shot and has been deactivated, it cannot reactivate.
var can_reactivate: bool = true
var machine: StateMachine

func process_behaviors(
	behaviors: Array[StateBehavior],
	method_name: StringName,
	callback: Callable = func(_result: Variant) -> bool: return false,
	...method_arguments: Array[Variant]
) -> void:
	for behavior in behaviors:
		if behavior.has_method(method_name):
			@warning_ignore("unsafe_method_access")
			var result: Variant

			if method_arguments.is_empty():
				result = behavior.call(method_name)
			else:
				result = behavior.callv(method_name, method_arguments)
			
			if callback.call(result) == true:
				break

func is_boolean_and_true(result: Variant) -> bool:
	return typeof(result) == TYPE_BOOL and result == true

signal on_initialized()
## Called after `machine` is set on the State from the parent StateMachine.
func initialize() -> void: on_initialized.emit.call_deferred()

signal on_entered()
var enter_behaviors: Array[StateBehavior] = []
## Called when the state is entered/activated.
func enter() -> void:
	process_behaviors(enter_behaviors, &"enter")
	on_entered.emit.call_deferred()

signal on_exited()
var exit_behaviors: Array[StateBehavior] = []
## Called when the state is exited/deactivated.
func exit() -> void:
	process_behaviors(exit_behaviors, &"exit")
	on_exited.emit.call_deferred()

## Function to check if the current state can activate before activating itself.
var can_activate: Callable = func() -> bool: return true

signal on_activated()
func activate() -> bool:
	if is_active or not can_reactivate or not can_activate.call(): return false

	is_active = true
	on_activated.emit()
	enter()
	
	return true

var reactivate_behaviors: Array[StateBehavior] = []
signal on_deactivated(can_reactivate: bool)
func deactivate(state_can_reactivate: bool = true) -> void:
	if not is_active: return
	if not state_can_reactivate: can_reactivate = false

	is_active = false
	on_deactivated.emit(can_reactivate)
	exit()

	if not can_reactivate: return
	
	process_behaviors(
		reactivate_behaviors,
		&"reactivate",
		func(result: Variant) -> bool:
			if is_boolean_and_true(result):
				activate()
				return true
			return false
	)

var validate_behaviors: Array[StateBehavior] = []
## Called to check whether to activate or deactivate the state.
func validate() -> void:
	process_behaviors(
		validate_behaviors,
		&"validate",
		func(result: Variant) -> bool:
			if is_boolean_and_true(result):
				activate()
				return true
			return false
	)

var physics_process_behaviors: Array[StateBehavior] = []
## Called every physics process frame if the state is active.
func physics_process(delta: float) -> void:
	process_behaviors(
		physics_process_behaviors,
		&"physics_process",
		func(_result: Variant) -> bool: return false,
		delta
	)

var render_process_behaviors: Array[StateBehavior] = []
## Called every render process frame if the state is active.
func render_process(delta: float) -> void:
	process_behaviors(
		render_process_behaviors,
		&"render_process",
		func(_result: Variant) -> bool: return false,
		delta
	)

var accumulated_validation_delta: float = 0.0
func process(delta: float) -> void:
	if not can_reactivate or not can_activate.call(): return

	if validation_interval > 0.0:
		accumulated_validation_delta += delta
		
		if accumulated_validation_delta >= validation_interval:
			validate()
			accumulated_validation_delta -= validation_interval

signal on_ready()
func _ready() -> void:
	if validations_per_second > 0:
		validation_interval = 1.0 / validations_per_second
		accumulated_validation_delta = randf() * validation_interval

	for child in get_children():
		if not child is StateBehavior: continue
		
		var state_behavior: StateBehavior = child
		state_behavior.state = self

		if state_behavior.has_method(&"enter"):
			enter_behaviors.append(state_behavior)
		if state_behavior.has_method(&"reactivate"):
			reactivate_behaviors.append(state_behavior)
		if state_behavior.has_method(&"validate"):
			validate_behaviors.append(state_behavior)
		if state_behavior.has_method(&"render_process"):
			render_process_behaviors.append(state_behavior)
		if state_behavior.has_method(&"physics_process"):
			physics_process_behaviors.append(state_behavior)
		if state_behavior.has_method(&"exit"):
			exit_behaviors.append(state_behavior)

	on_ready.emit.call_deferred()
