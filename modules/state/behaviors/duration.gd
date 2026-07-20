@tool
extends StateBehavior
## Behavior that deactivates the state after a given duration
class_name StateBehaviorDuration

## Duration (in seconds)
@export_range(0.001, 10.0, 0.001) var duration: float = 3.0
## Duration variance (in seconds)
@export_range(0.0, 10.0, 0.001) var duration_variance: float = 0.0

var current_duration: float = 0.0
func enter() -> void:
	current_duration = duration + randf_range(-duration_variance, duration_variance)

var accumulated_delta: float = 0.0
func physics_process(delta: float) -> void:
	accumulated_delta += delta
	if accumulated_delta <= current_duration: return
	accumulated_delta = 0.0
	state.deactivate()
