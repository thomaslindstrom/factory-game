@tool
extends TileMapLayer
class_name StalbergTileMapLayer

@export_tool_button("Render") var button_render: Callable = render

const DISPLAY_OFFSETS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]

var atlas_by_mask: Dictionary = {}
var _display: TileMapLayer


func build_atlas_lookup() -> void:
	atlas_by_mask.clear()
	if not tile_set or tile_set.get_source_count() == 0:
		return

	var source: TileSetAtlasSource = tile_set.get_source(0) as TileSetAtlasSource
	if not source:
		return

	for i in source.get_tiles_count():
		var coords: Vector2i = source.get_tile_id(i)
		var data: TileData = source.get_tile_data(coords, 0)
		var mask: int = 0

		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER) == 0:
			mask |= 8
		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER) == 0:
			mask |= 4
		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER) == 0:
			mask |= 2
		if data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER) == 0:
			mask |= 1

		atlas_by_mask[mask] = coords


func _ensure_display() -> TileMapLayer:
	if is_instance_valid(_display):
		return _display

	_display = get_node_or_null("Display") as TileMapLayer
	if _display:
		return _display

	_display = TileMapLayer.new()
	_display.name = "Display"
	add_child(_display)
	return _display


func render() -> void:
	var display := _ensure_display()
	display.tile_set = tile_set
	display.clear()
	build_atlas_lookup()

	var filled: Dictionary = {}
	for cell in get_used_cells():
		filled[cell] = true

	if filled.is_empty():
		display.visible = false
		self_modulate = Color.WHITE
		return

	# Keep painted cells editable in the editor; hide them at runtime.
	self_modulate = Color.WHITE if Engine.is_editor_hint() else Color(1, 1, 1, 0)
	display.visible = true
	display.position = -Vector2(tile_set.tile_size) * 0.5 - Vector2(0.5, 0.5)

	var display_cells: Dictionary = {}
	for cell in filled:
		for offset in DISPLAY_OFFSETS:
			display_cells[cell + offset] = true

	for display_coord in display_cells:
		var mask: int = 0
		if filled.has(display_coord + Vector2i(-1, -1)):
			mask |= 8
		if filled.has(display_coord + Vector2i(0, -1)):
			mask |= 4
		if filled.has(display_coord + Vector2i(-1, 0)):
			mask |= 2
		if filled.has(display_coord):
			mask |= 1
		if mask == 0 or not atlas_by_mask.has(mask):
			continue

		display.set_cell(display_coord, 0, atlas_by_mask[mask])


func _ready() -> void:
	render()
