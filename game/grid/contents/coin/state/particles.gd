@tool
extends StateBehavior

@export var particles: GPUParticles2D

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not particles: warnings.append("`particles` is not set")
	return warnings

func enter() -> void:
	particles.restart()
	particles.emitting = true

func exit() -> void:
	particles.emitting = false
