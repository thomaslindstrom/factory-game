extends Node2D
class_name Draggable

var original_position: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
func start(drag_position: Vector2) -> void:
	original_position = global_position
	is_dragging = true
	drag_offset = global_position - drag_position
	z_index = 100

func update(drag_position: Vector2) -> void:
	global_position = drag_position + drag_offset

func animate_position(new_position: Vector2, duration: float = 0.2) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", new_position, duration)

func stop() -> void:
	is_dragging = false
	z_index = 0
