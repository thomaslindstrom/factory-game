extends Node2D

@export var grid: Grid
@export var old_drop_texture: AtlasTexture
@export var new_drop_texture: AtlasTexture

var old_sprite: Sprite2D
var new_sprite: Sprite2D
var preview_scene: Node2D

func clear_preview_scene() -> void:
	if preview_scene: preview_scene.queue_free()
	preview_scene = null

func handle_invalid_drop_hover() -> void:
	if old_sprite: old_sprite.visible = false
	if new_sprite: new_sprite.visible = false

func handle_drop_hover(item: GridItem) -> void:
	if not old_sprite:
		old_sprite = Sprite2D.new()
		old_sprite.texture = old_drop_texture.atlas
		old_sprite.region_enabled = true
		old_sprite.region_rect = old_drop_texture.region
		old_sprite.visible = false
		add_child(old_sprite)
	
	if not new_sprite:
		new_sprite = Sprite2D.new()
		new_sprite.texture = new_drop_texture.atlas
		new_sprite.region_enabled = true
		new_sprite.region_rect = new_drop_texture.region
		new_sprite.visible = false
		add_child(new_sprite)

	old_sprite.visible = true
	old_sprite.global_position = grid.to_global(grid.coordinates_to_position(item.coordinates))

	if not Game.is_grid_drop_valid or Game.grid_drop_coordinates == null or typeof(Game.grid_drop_coordinates) != TYPE_VECTOR2I:
		handle_invalid_drop_hover()
		return

	var coordinates: Vector2i = Game.grid_drop_coordinates
	
	if grid.grid_map.has(coordinates):
		if item.coordinates == coordinates: 
			clear_preview_scene()
			old_sprite.visible = false
		
		new_sprite.visible = false
		return

	var grid_position: Vector2 = grid.to_global(grid.coordinates_to_position(coordinates))

	if item.content.resource.drop_preview_scene:
		if preview_scene: clear_preview_scene()
		preview_scene = item.content.resource.drop_preview_scene.instantiate()
		add_child(preview_scene)
		preview_scene.global_position = grid_position

	new_sprite.visible = true
	new_sprite.global_position = grid_position

func handle_drop_hover_end() -> void:
	if old_sprite: old_sprite.visible = false
	if new_sprite: new_sprite.visible = false
	clear_preview_scene()

func _ready() -> void:
	Game.on_grid_drop_hover.connect(handle_drop_hover.call_deferred)
	Game.on_grid_drop_hover_end.connect(handle_drop_hover_end.call_deferred)
