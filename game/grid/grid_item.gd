extends Node2D
class_name GridItem

var grid: Grid
var coordinates: Vector2i
var content: GridItemContent
var drag: Draggable = Draggable.new(self )

func _init(input_content: GridItemContent) -> void:
	self.content = input_content
	input_content.item = self

func animate_position(new_position: Vector2, duration: float = 0.2) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self , "position", new_position, duration)

func animate_return(duration: float = 0.4) -> void:
	animate_position(grid.coordinates_to_position(coordinates), duration)

func handle_drag_move() -> void:
	Game.on_grid_drop_hover.emit(self )

func handle_drag_drop() -> void:
	Game.on_grid_drop_hover_end.emit()
	var mouse_position: Vector2 = grid.get_mouse_position()
	var target: Vector2i = grid.global_position_to_coordinates(mouse_position)
	
	if not grid.move_item(self , target): animate_return()

func handle_drag_return() -> void:
	Game.on_grid_drop_hover_end.emit()
	animate_return(0.2)

func handle_area_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	drag.handle_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if not drag.is_dragging: return
	drag.handle_input(event)

func _ready() -> void:
	drag.handle_move = handle_drag_move
	drag.handle_drop = handle_drag_drop
	drag.return_to_original_position = handle_drag_return

	if not content: return
	add_child(content)
	content.area.input_event.connect(handle_area_input)

func _process(_delta: float) -> void:
	drag.process()
