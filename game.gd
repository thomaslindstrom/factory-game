extends Node

var grid: Grid

signal on_score_changed(score: int)
var score: int = 10:
	set(value):
		score = value
		on_score_changed.emit(score)

# Shop
var is_shop_drop_valid: bool = true
var shop_drop_coordinates: Variant
signal on_shop_drop_hover(item: ShopItem)
signal on_shop_drop_hover_end()

func handle_shop_drop_hover(item: ShopItem) -> void:
	var mouse_position: Vector2 = grid.get_mouse_position()
	var coordinates: Vector2i = grid.global_position_to_coordinates(mouse_position)
	shop_drop_coordinates = coordinates

func handle_shop_drop_hover_end() -> void:
	shop_drop_coordinates = null

func _ready() -> void:
	on_shop_drop_hover.connect(handle_shop_drop_hover)
	on_shop_drop_hover_end.connect(handle_shop_drop_hover_end.call_deferred)

func try_shop_drop_purchase(item: ShopItem) -> bool:
	if not grid or not is_shop_drop_valid: return false
	if shop_drop_coordinates == null: return false
	if typeof(shop_drop_coordinates) != TYPE_VECTOR2I: return false

	var coordinates: Vector2i = shop_drop_coordinates
	if grid.grid_map.has(coordinates): return false
	if score < item.price: return false

	var grid_item: GridItem = GridItem.new(item.grid_item.create())
	grid.add_item(grid_item, coordinates)

	score -= item.price
	return true
