@tool
extends State

@export var grid_item_content: GridItemContent
@export var next_state: State

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not grid_item_content: warnings.append("`grid_item_content` is not set")
	if not next_state: warnings.append("`next_state` is not set")
	return warnings

var index_offset: int = 0
func enter() -> void:
	super.enter()

	var neighbors: Array[GridItem] = grid_item_content.item.grid.get_neighbors(grid_item_content.item.coordinates)
	var neighbors_count: int = neighbors.size()

	if neighbors_count == 0: return
	for index in neighbors_count:
		var current_index: int = (index_offset + index) % neighbors_count
		var neighbor: GridItem = neighbors[current_index]

		if not neighbor.content.resource.can_activate: continue
		if not neighbor.content.activate(): continue

		next_state.activate()
		index_offset = current_index + 1
		return
