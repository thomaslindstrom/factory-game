@tool
extends Node2D

@export var tile_set: TileSet
@export var effect_area: Array[Vector2i] = []
@export_tool_button("Render") var button_render: Callable = render

const DISPLAY_OFFSETS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]

var layer: TileMapLayer
var atlas_by_mask: Dictionary = {}

func build_atlas_lookup() -> void:
	atlas_by_mask.clear()
	if not tile_set or tile_set.get_source_count() == 0: return

	var source: TileSetAtlasSource = tile_set.get_source(0) as TileSetAtlasSource
	if not source: return

	for i in source.get_tiles_count():
		var coords: Vector2i = source.get_tile_id(i)
		var data: TileData = source.get_tile_data(coords, 0)
		var mask: int = 0
		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER) == 0: mask |= 8
		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER) == 0: mask |= 4
		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER) == 0: mask |= 2
		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER) == 0: mask |= 1
		atlas_by_mask[mask] = coords

func render() -> void:
	if not layer:
		layer = TileMapLayer.new()
		add_child(layer)

	layer.tile_set = tile_set
	layer.clear()
	build_atlas_lookup()

	if effect_area.is_empty():
		layer.visible = false
		return

	layer.visible = true
	layer.position = - Vector2(tile_set.tile_size) - Vector2(0.5, 0.5)

	var filled: Dictionary = {}
	for cell in effect_area: filled[cell] = true

	var display_cells: Dictionary = {}
	
	for cell in filled: for offset in DISPLAY_OFFSETS:
		display_cells[cell + offset] = true

	for display_coord in display_cells:
		var mask: int = 0
		
		if filled.has(display_coord + Vector2i(-1, -1)): mask |= 8
		if filled.has(display_coord + Vector2i(0, -1)): mask |= 4
		if filled.has(display_coord + Vector2i(-1, 0)): mask |= 2
		if filled.has(display_coord): mask |= 1
		if mask == 0 or not atlas_by_mask.has(mask): continue
		
		layer.set_cell(display_coord, 0, atlas_by_mask[mask])

func _ready() -> void:
	render()
