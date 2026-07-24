@tool
extends Control
class_name UiShopItem

@export var shop_item: ShopItemResource

@onready var container: Container = %Container
@onready var sprite: Sprite2D = %Sprite2D
@onready var text: UiText = %UiText
@onready var hover: Sprite2D = %Hover

var drag: Draggable = Draggable.new(self )

func can_afford_shop_item(coins: int = Game.coins) -> bool:
	return coins >= shop_item.price

func handle_coins_changed(new_coins: int, animation_duration: float = 0.2) -> void:
	var tween: Tween = create_tween()
	var opacity: float = 1.0 if can_afford_shop_item(new_coins) else 0.25
	tween.tween_property(container, "modulate:a", opacity, animation_duration)

func handle_mouse_entered() -> void:
	if not can_afford_shop_item(): return
	var tween: Tween = create_tween()
	tween.tween_property(hover, "modulate:a", 1.0, 0.1)

func handle_mouse_exited() -> void:
	if not can_afford_shop_item(): return
	var tween: Tween = create_tween()
	tween.tween_property(hover, "modulate:a", 0.0, 0.2)

func animate_global_position(new_global_position: Vector2, duration: float = 0.2) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self , "global_position", new_global_position, duration)

var is_offset: bool = false
func animate_container_position(should_offset: bool = true) -> void:
	if is_offset == should_offset: return
	is_offset = should_offset

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(container, "position", -drag.drag_offset + Vector2(6.0, 8.0) if should_offset else Vector2.ZERO, 0.1)

func handle_drag_move() -> void:
	Game.on_shop_drop_hover.emit(shop_item)
	animate_container_position(Game.is_shop_drop_valid)

func handle_drag_drop() -> void:
	Game.on_shop_drop_hover_end.emit()
	
	if Game.try_shop_drop_purchase(shop_item):
		var tween: Tween = create_tween()
		tween.tween_property(self , "modulate:a", 0.0, 0.1)
		tween.tween_property(self , "global_position", drag.original_position, 0.0)
		tween.tween_property(self , "modulate:a", 1.0, 0.1)
	else: animate_global_position(drag.original_position)
	
	animate_container_position(false)

func handle_drag_return() -> void:
	Game.on_shop_drop_hover_end.emit()
	animate_global_position(drag.original_position)
	animate_container_position(false)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	drag.process()

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	drag.is_draggable = can_afford_shop_item() and get_global_rect().has_point(get_global_mouse_position())
	drag.handle_input(event)

func _ready() -> void:
	drag.handle_move = handle_drag_move
	drag.handle_drop = handle_drag_drop
	drag.return_to_original_position = handle_drag_return

	if not Engine.is_editor_hint():
		Game.on_coins_changed.connect(handle_coins_changed)
		handle_coins_changed(Game.coins, 0.0)

	hover.modulate.a = 0.0
	mouse_entered.connect(handle_mouse_entered)
	mouse_exited.connect(handle_mouse_exited)

	if not shop_item or not sprite: return
	sprite.texture = shop_item.sprite.atlas
	sprite.region_enabled = true
	sprite.region_rect = shop_item.sprite.region
	text.text = str(shop_item.price)
