@tool
extends Control
class_name UiText

@export_multiline var text: String = "": 
	set(value):
		text = value
		render.call_deferred()

func resize(text_sprite_size: Vector2i) -> void:
	custom_minimum_size = text_sprite_size
	size = text_sprite_size

var text_sprite: TextSprite2D
func render() -> void:
	if not text_sprite: 
		text_sprite = TextSprite2D.new()
		text_sprite.on_after_rendered.connect(resize)
		add_child(text_sprite)
	text_sprite.text = text

func _ready() -> void:
	render()
