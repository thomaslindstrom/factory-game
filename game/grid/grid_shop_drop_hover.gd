extends Node2D

@export var grid: Grid
@export var purchase_texture: AtlasTexture

var sprite: Sprite2D
var preview_scene: Node2D

func clear_preview_scene() -> void:
	if preview_scene: preview_scene.queue_free()
	preview_scene = null

func handle_invalid_shop_drop_hover() -> void:
	if sprite: sprite.visible = false

func handle_shop_drop_hover(item: ShopItemResource) -> void:
	if not sprite:
		sprite = Sprite2D.new()
		sprite.texture = purchase_texture.atlas
		sprite.region_enabled = true
		sprite.region_rect = purchase_texture.region
		sprite.visible = false
		add_child(sprite)

	if not Game.is_shop_drop_valid or Game.shop_drop_coordinates == null or typeof(Game.shop_drop_coordinates) != TYPE_VECTOR2I:
		clear_preview_scene()
		handle_invalid_shop_drop_hover()
		return

	var coordinates: Vector2i = Game.shop_drop_coordinates
	
	if grid.grid_map.has(coordinates):
		clear_preview_scene()
		sprite.visible = false
		return
	
	var grid_position: Vector2 = grid.to_global(grid.coordinates_to_position(coordinates))

	if item.grid_drop_preview_scene:
		if preview_scene: clear_preview_scene()
		preview_scene = item.grid_drop_preview_scene.instantiate()
		add_child(preview_scene)
		preview_scene.global_position = grid_position

	sprite.visible = true
	sprite.global_position = grid.to_global(grid.coordinates_to_position(coordinates))

func handle_shop_drop_hover_end() -> void:
	if sprite: sprite.visible = false
	clear_preview_scene()

func _ready() -> void:
	Game.on_shop_drop_hover.connect(handle_shop_drop_hover.call_deferred)
	Game.on_shop_drop_hover_end.connect(handle_shop_drop_hover_end.call_deferred)
