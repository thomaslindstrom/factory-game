extends Node

var grid: Grid

signal on_coins_changed(coins: int)
var coins: int = 1:
	set(value):
		coins = value
		on_coins_changed.emit(value)

signal on_food_changed(food: int)
var food: int = 10:
	set(value):
		food = value
		on_food_changed.emit(value)

# Grid
var is_grid_drop_valid: bool = true
var grid_drop_coordinates: Variant
var previous_grid_drop_coordinates: Variant
signal on_grid_drop_hover(item: GridItem)
signal on_grid_drop_hover_end()

func handle_grid_drop_hover(_item: GridItem) -> void:
	var mouse_position: Vector2 = grid.get_mouse_position()
	var new_coordinates: Vector2i = grid.global_position_to_coordinates(mouse_position)
	previous_grid_drop_coordinates = grid_drop_coordinates if grid_drop_coordinates else new_coordinates
	grid_drop_coordinates = new_coordinates
	
func handle_grid_drop_hover_end() -> void:
	previous_grid_drop_coordinates = grid_drop_coordinates
	grid_drop_coordinates = null

# Shop
var is_shop_drop_valid: bool = true
var shop_drop_coordinates: Variant
var previous_shop_drop_coordinates: Variant
signal on_shop_drop_hover(item: ShopItemResource)
signal on_shop_drop_hover_end()

func handle_shop_drop_hover(_item: ShopItemResource) -> void:
	var mouse_position: Vector2 = grid.get_mouse_position()
	var new_coordinates: Vector2i = grid.global_position_to_coordinates(mouse_position)
	previous_shop_drop_coordinates = shop_drop_coordinates if shop_drop_coordinates else new_coordinates
	shop_drop_coordinates = new_coordinates

func handle_shop_drop_hover_end() -> void:
	previous_shop_drop_coordinates = shop_drop_coordinates
	shop_drop_coordinates = null

func try_shop_drop_purchase(item: ShopItemResource) -> bool:
	if not grid or not is_shop_drop_valid: return false
	if shop_drop_coordinates == null: return false
	if typeof(shop_drop_coordinates) != TYPE_VECTOR2I: return false

	var coordinates: Vector2i = shop_drop_coordinates
	if grid.grid_map.has(coordinates): return false
	if coins < item.price: return false

	var grid_item: GridItem = GridItem.new(item.grid_item.create())
	grid.add_item(grid_item, coordinates)

	coins -= item.price
	return true
	
# Lifecycle
func _ready() -> void:
	on_grid_drop_hover.connect(handle_grid_drop_hover)
	on_grid_drop_hover_end.connect(handle_grid_drop_hover_end)
	on_shop_drop_hover.connect(handle_shop_drop_hover)
	on_shop_drop_hover_end.connect(handle_shop_drop_hover_end.call_deferred)
