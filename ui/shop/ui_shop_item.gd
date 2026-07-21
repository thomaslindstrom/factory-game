@tool
extends Control
class_name UiShopItem

@export var shop_item: ShopItem

@onready var sprite: Sprite2D = %Sprite2D
@onready var text: UiText = %UiText
@onready var hover: Sprite2D = %Hover

func handle_score_changed(new_score: int) -> void:
	var tween: Tween = create_tween()
	var opacity: float = 1.0 if new_score >= shop_item.price else 0.25
	tween.tween_property(self , "modulate:a", opacity, 0.2)

func handle_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(hover, "modulate:a", 1.0, 0.1)

func handle_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(hover, "modulate:a", 0.0, 0.2)

func animate_global_position(new_global_position: Vector2, duration: float = 0.2) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self , "global_position", new_global_position, duration)

var original_position: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
func stop_dragging() -> void:
	if not is_dragging: return
	
	Game.on_shop_drop_hover_end.emit()
	is_dragging = false
	z_index = 0

	if Game.try_shop_drop_purchase(shop_item):
		var tween: Tween = create_tween()
		tween.tween_property(self , "modulate:a", 0.0, 0.1)
		tween.tween_property(self , "global_position", original_position, 0.0)
		tween.tween_property(self , "modulate:a", 1.0, 0.1)
	else: animate_global_position(original_position)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed(&"primary"):
		if is_dragging:
			stop_dragging()
			return

		var mouse_position: Vector2 = get_global_mouse_position()
		
		if get_global_rect().has_point(mouse_position):
			original_position = global_position
			is_dragging = true
			drag_offset = global_position - mouse_position
			z_index = 100
			Game.on_shop_drop_hover.emit(shop_item)
	elif event.is_action_released(&"primary"):
		stop_dragging()

	if is_dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
		Game.on_shop_drop_hover.emit(shop_item)
		get_viewport().set_input_as_handled()

func _ready() -> void:
	Game.on_score_changed.connect(handle_score_changed)
	handle_score_changed(Game.score)

	hover.modulate.a = 0.0
	mouse_entered.connect(handle_mouse_entered)
	mouse_exited.connect(handle_mouse_exited)
	
	if not shop_item or not sprite: return
	sprite.texture = shop_item.sprite.atlas
	sprite.region_enabled = true
	sprite.region_rect = shop_item.sprite.region
	text.text = str(shop_item.price)
