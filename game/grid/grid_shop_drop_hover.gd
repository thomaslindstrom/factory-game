extends Node2D

@export var grid: Grid
@export var purchase_texture: AtlasTexture

var sprite: Sprite2D
func handle_invalid_shop_drop_hover() -> void:
	if sprite: sprite.visible = false

func handle_shop_drop_hover(item: ShopItem) -> void:
	if not sprite:
		sprite = Sprite2D.new()
		sprite.texture = purchase_texture.atlas
		sprite.region_enabled = true
		sprite.region_rect = purchase_texture.region
		sprite.visible = false
		add_child(sprite)

	if not Game.is_shop_drop_valid or Game.shop_drop_coordinates == null or typeof(Game.shop_drop_coordinates) != TYPE_VECTOR2I:
		handle_invalid_shop_drop_hover()
		return

	var coordinates: Vector2i = Game.shop_drop_coordinates
	
	if grid.grid_map.has(coordinates):
		sprite.visible = false
		return

	sprite.visible = true
	sprite.global_position = grid.to_global(grid.get_grid_item_position(coordinates))

func handle_shop_drop_hover_end() -> void:
	sprite.visible = false

func _ready() -> void:
	Game.on_shop_drop_hover.connect(handle_shop_drop_hover.call_deferred)
	Game.on_shop_drop_hover_end.connect(handle_shop_drop_hover_end.call_deferred)
