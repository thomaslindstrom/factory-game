extends Node2D
class_name GridItem

var grid: Grid
var coordinates: Vector2i
var content: GridItemContent

func _init(input_content: GridItemContent) -> void:
	self.content = input_content
	input_content.item = self

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
func handle_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(&"primary"):
		is_dragging = true
		drag_offset = global_position - get_global_mouse_position()
		z_index = 100

func animate_position(new_position: Vector2, duration: float = 0.2) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", new_position, duration)

func handle_drop() -> void:
	var target: Vector2i = grid.global_position_to_coordinates(global_position)

	if not grid.move_item(self, target):
		animate_position(grid.get_grid_item_position(coordinates), 0.4)

func _input(event: InputEvent) -> void:
	if not is_dragging: return

	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
		get_viewport().set_input_as_handled()
	elif event.is_action_released(&"primary"):
		is_dragging = false
		z_index = 0
		get_viewport().set_input_as_handled()
		handle_drop()

func _ready() -> void:
	if not content: return
	add_child(content)
	content.area.input_event.connect(handle_input)
