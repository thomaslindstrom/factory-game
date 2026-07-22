extends RefCounted
## Drag-and-drop helper for any [CanvasItem] ([Node2D] or [Control]).
##
## Owns drag state and follow positioning. Assign the [code]handle_*[/code] callables for drop/cancel/move behavior. Call [method process] every frame so the drag tracks when the camera moves as well.
##
## Usage:
## [codeblock]
## var drag: Draggable = Draggable.new(self)
##
## func _ready() -> void:
##     drag.handle_drop = handle_drag_drop
##     drag.return_to_original_position = handle_drag_return
##     drag.handle_move = handle_drag_move
##
## func _process(_delta: float) -> void:
##     drag.process()
##
## func _input(event: InputEvent) -> void:
##     # drag.is_draggable = true
##     drag.handle_input(event)
## [/codeblock]
##
## Set [member is_draggable] before [method handle_input] to gate whether a drag can start.
class_name Draggable

var is_draggable: bool = true
var original_z_index: int = 0
var target: CanvasItem

## Called when the dragged element is moved, and at drag start
var handle_move: Callable = func() -> void: pass
## Called when the dragged item is dropped
var handle_drop: Callable = func() -> void: pass
## Called when the drag is cancelled and the item should return to where it was
var return_to_original_position: Callable = func() -> void: pass

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

func _init(input_target: CanvasItem) -> void:
	target = input_target
	return_to_original_position = func() -> void:
		target.global_position = original_position

func handle_dragging() -> void:
	if not is_dragging: return
	target.global_position = target.get_global_mouse_position() + drag_offset
	handle_move.call()

func process() -> void:
	handle_dragging()

func start_dragging() -> void:
	if is_dragging or not is_draggable: return
	original_z_index = target.z_index
	original_position = target.global_position
	is_dragging = true
	drag_offset = target.global_position - target.get_global_mouse_position()
	target.z_index = original_z_index + 100
	handle_move.call()

func stop_dragging() -> void:
	if not is_dragging: return
	is_dragging = false
	handle_drop.call()
	target.z_index = original_z_index

func cancel_dragging() -> void:
	if not is_dragging: return
	is_dragging = false
	return_to_original_position.call()
	target.z_index = original_z_index

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"primary"):
		if is_dragging:
			stop_dragging()
			target.get_viewport().set_input_as_handled()
		elif is_draggable and not target.get_viewport().is_input_handled():
			start_dragging()
			target.get_viewport().set_input_as_handled()
	elif event.is_action_released(&"primary"):
		if not is_dragging: return
		stop_dragging()
		target.get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"cancel"):
		if not is_dragging: return
		cancel_dragging()
		target.get_viewport().set_input_as_handled()
