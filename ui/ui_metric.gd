@tool
extends MarginContainer
class_name UiMetric

@export var texture: AtlasTexture:
	set(value):
		texture = value
		update_sprite()
@export var text: String = "":
	set(value):
		text = value
		update_text()

@onready var sprite: Sprite2D = %Sprite2D
@onready var ui_text: UiText = %UiText

func update_sprite() -> void:
	if texture and sprite: sprite.texture = texture

func update_text() -> void:
	if text: ui_text.text = text
