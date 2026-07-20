@tool
extends Node2D
class_name TextSprite2D

@export_multiline var text: String = "":
	set(value):
		text = value
		queue_render()

@export_group("Settings")
@export_range(0, 10, 1, "or_less", "or_greater") var letter_spacing: int = 1:
	set(value):
		letter_spacing = value
		queue_render()
@export_range(0, 10, 1, "or_less", "or_greater") var line_spacing: int = 0:
	set(value):
		line_spacing = value
		queue_render()
@export_group("")

var characters: Array[CharacterSprite2D] = []

signal on_before_rendered(character: String, sprite: CharacterSprite2D)
signal on_rendered(character: String, sprite: CharacterSprite2D)
signal on_after_rendered(size: Vector2i)
func render() -> void:
	for child in get_children(): child.queue_free()
	characters.clear()

	var space_character_sprite: CharacterSprite2D = CharacterSprite2D.new()
	space_character_sprite.character = " "
	if not space_character_sprite.render(): return

	var line_height: int = 0
	var width: int = 0
	var offset_x: int = 0
	var offset_y: int = 0

	for character in text:
		if character == '\n':
			offset_x = 0

			if line_height == 0: offset_y += space_character_sprite.height
			else: offset_y += line_height

			offset_y += line_spacing
			line_height = 0
			continue
		
		var character_sprite: CharacterSprite2D = CharacterSprite2D.new()
		character_sprite.character = character
		
		on_before_rendered.emit(character, character_sprite)
		if not character_sprite.render(): continue

		character_sprite.position.x = offset_x
		character_sprite.position.y = offset_y
		offset_x += character_sprite.width
		width = max(width, offset_x)
		offset_x += letter_spacing
		line_height = max(line_height, character_sprite.height)

		characters.append(character_sprite)
		add_child(character_sprite)

		on_rendered.emit(character, character_sprite)

	on_after_rendered.emit(Vector2i(width, offset_y + line_height))

var is_rendering: bool = false
func flush_render() -> void:
	is_rendering = false
	render()

func queue_render() -> void:
	if is_rendering: return
	is_rendering = true
	flush_render.call_deferred()
