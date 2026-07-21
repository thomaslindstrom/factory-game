@tool
extends State

@export var grid_item_content: GridItemContentActivator
@export var next_state: State

@onready var orthogonal_target: Sprite2D = %OrthogonalTarget
@onready var diagonal_target: Sprite2D = %DiagonalTarget

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not grid_item_content: warnings.append("`grid_item_content` is not set")
	if not next_state: warnings.append("`next_state` is not set")
	return warnings

func reset() -> void:
	orthogonal_target.visible = false
	diagonal_target.visible = false

const quarter_pi: float = PI / 4.0
const half_pi: float = PI / 2.0

func update_target(neighbor: GridItem) -> void:
	var direction: Vector2i = neighbor.coordinates - grid_item_content.item.coordinates
	var angle: float = Vector2(direction).angle()
	var orthogonal_angle: float = snappedf(angle, half_pi)
	var is_orthogonal: bool = is_equal_approx(orthogonal_angle, angle)
	var target: Sprite2D = orthogonal_target if is_orthogonal else diagonal_target
	var other_target: Sprite2D = diagonal_target if is_orthogonal else orthogonal_target
	
	other_target.visible = false
	target.visible = true
	target.rotation = snappedf(angle + half_pi, half_pi) if is_orthogonal else snappedf(angle + half_pi + quarter_pi, quarter_pi)

var index_offset: int = 0
func enter() -> void:
	super.enter()
	
	var neighbors: Array[GridItem] = grid_item_content.item.grid.get_neighbors(grid_item_content.item.coordinates, grid_item_content.neighbor_filter)
	var neighbors_count: int = neighbors.size()

	if neighbors_count == 0:
		reset() 
		return
	
	for index in neighbors_count:
		var current_index: int = (index_offset + index) % neighbors_count
		var neighbor: GridItem = neighbors[current_index]

		if not neighbor.content.resource.can_activate: continue
		if not neighbor.content.activate(): continue

		index_offset = current_index + 1
		update_target(neighbor)
		next_state.activate()
		return
	
	reset()
