extends Node2D
class_name GridItemContentsCooldown

@export_range(0.0, 10.0, 0.01, "or_greater") var duration: float = 0.0
@onready var sprite: Sprite2D = %Sprite2D

var timer: float = 0.0
func reset() -> void:
	timer = 0.0

func _process(delta: float) -> void:
	if timer >= duration: return
	
	timer += delta
	sprite.modulate.a = Global.smoothstep_band(0.0, 0.2, 0.9, 1.0, timer / duration)

	sprite.visible = sprite.modulate.a > 0.0
	
func _ready() -> void:
	sprite.visible = duration > 0.0
