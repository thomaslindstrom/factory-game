@tool
extends Node2D
class_name GridItemContent

@export_group("Frame color")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "checkbox_only") var use_frame_color: bool = false:
	set(value):
		use_frame_color = value
		render()
@export var frame_color: Color = Color.WHITE:
	set(value):
		frame_color = value
		render()

var item: GridItem
var resource: GridItemContentResource

@onready var frame: Sprite2D = %Frame
@onready var hover: Sprite2D = %Hover
@onready var area: Area2D = %Area2D

func activate() -> bool: return false

static var frame_materials: Dictionary[String, ShaderMaterial] = {}

func render() -> void:
	if not frame: return
	var key: String = frame_color.to_html()

	if frame_materials.has(key):
		frame.material = frame_materials.get(key)
	else:
		var frame_material: ShaderMaterial = frame.material.duplicate()
		frame_material.set_shader_parameter("use_color", use_frame_color)
		frame_material.set_shader_parameter("color", frame_color)
		frame.material = frame_material
		frame_materials.set(key, frame_material)
		
func handle_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(hover, "modulate:a", 1.0, 0.1)

func handle_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(hover, "modulate:a", 0.0, 0.2)

func _ready() -> void:
	hover.modulate.a = 0.0
	area.mouse_entered.connect(handle_mouse_entered)
	area.mouse_exited.connect(handle_mouse_exited)
