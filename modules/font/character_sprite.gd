@tool
extends Node2D
class_name CharacterSprite2D

@export var character: String = "":
	set(value):
		character = value.left(1)

@export_group("Font")
@export var font: Texture2D = preload("res://modules/font/font.png")
@export_multiline("monospace") var characters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZÆØÅabcdefghijklmnopqrstuvwxyzæøå-+=_/()<>'\"’:;.,!?%&° 0123456789"
@export var guide_position: int = 10
@export_group("")

var width: int = 0
var height: int = 0

static var character_maps: Array[String] = []
static var character_map: Dictionary[String, Vector4i] = {}

func get_character_map_id() -> String:
	var font_file_id: String = str(font.get_rid().get_id())
	var guide_position_string: String = str(guide_position)
	
	return font_file_id + '-' + guide_position_string + '-' + characters
	
func get_character_id() -> String:
	return get_character_map_id() + '-' + character

func generate_character_map() -> void:
	if not font: return
	
	var character_map_id = get_character_map_id()
	if character_maps.has(character_map_id): return
	character_maps.append(character_map_id)

	var image: Image = font.get_image()
	var image_height: int = image.get_height()

	if guide_position < 0 or guide_position >= image_height:
		return

	var image_width: int = image.get_width()
	var previous_character_x: int = 0

	for current_character in characters:
		var current_character_id: String = character_map_id + '-' + current_character
		var current_character_x: int = previous_character_x
		var character_width: int = 0
	
		while (current_character_x + character_width) < image_width:
			var pixel: Color = image.get_pixel(
				current_character_x + character_width,
				guide_position
			)

			if character_width == 0 and pixel.a == 0.0:
				current_character_x += 1
				continue

			character_width += 1
			if pixel.a == 0.0: break
		
		character_map[current_character_id] = Vector4i(
			current_character_x,
			0,
			guide_position - 1,
			character_width - 1,
		)

		previous_character_x = current_character_x + character_width

var sprite: Sprite2D

signal on_rendered()
func render() -> bool:
	if not character: return false
	var character_id: String = get_character_id()

	if character_map.is_empty():
		push_warning("Character map is empty")
		return false
		
	if not character_map.has(character_id):
		push_warning("Character data not found for character: %s" % character)
		return false

	var character_data: Vector4i = character_map.get(character_id)
	var region: Rect2 = Rect2(
		character_data.x,
		character_data.y,
		character_data.w,
		character_data.z
	)

	width = character_data.w
	height = character_data.z

	if not sprite:
		sprite = Sprite2D.new()
		sprite.texture = font
		sprite.centered = false
		sprite.region_enabled = true
		sprite.region_rect = region
		add_child(sprite)
	else: sprite.region_rect = region

	on_rendered.emit()
	return true

var is_rendering: bool = false
func flush_render() -> void:
	is_rendering = false
	render()

func queue_render() -> void:
	if is_rendering: return
	is_rendering = true
	flush_render.call_deferred()

func _init() -> void:
	generate_character_map()
