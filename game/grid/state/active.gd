@tool
extends StateBehaviorDuration

@export var cooldown: GridItemContentsCooldown
@export var animation_player: AnimationPlayer

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not cooldown: warnings.append("`cooldown` is not set")
	if not animation_player: warnings.append("`animation_player` is not set")
	return warnings

func enter() -> void:
	super.enter()
	cooldown.duration = duration
	cooldown.reset()

	animation_player.seek(0.0)
	animation_player.play("wobble")
