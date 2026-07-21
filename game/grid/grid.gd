@tool
extends Node2D
class_name Grid

@export var grid_size: Vector2i = Vector2i(512, 512)
@export var texture: AtlasTexture
@export var shader: Shader
@export var opacity: float = 0.25
@export var fade_radius: float = 4.0

var grid: Array[GridItem] = []
var grid_map: Dictionary[Vector2i, GridItem] = {}
var center: Vector2 = Vector2.ZERO

func get_grid_item_size() -> Vector2:
	return texture.region.size

func get_grid_position() -> Vector2:
	return -center * get_grid_item_size()

func get_grid_item_position(coordinates: Vector2i) -> Vector2:
	return get_grid_position() + (Vector2(coordinates) * get_grid_item_size())

func get_mouse_position() -> Vector2:
	return get_global_mouse_position()

func global_position_to_coordinates(input_global_position: Vector2) -> Vector2i:
	return (to_local(input_global_position) - get_grid_position()) / get_grid_item_size() + Vector2.ONE * 0.5

var multimesh_instance: MultiMeshInstance2D
var multimesh: MultiMesh

@export_tool_button("Render") var button_render: Callable = func() -> void:
	if multimesh_instance: multimesh_instance.queue_free()
	multimesh_instance = null
	build()

func clear() -> void:
	for item in grid: item.queue_free()
	grid.clear()
	grid_map.clear()

func get_closest_item(coordinates: Vector2i) -> GridItem:
	if grid_map.has(coordinates): return grid_map.get(coordinates)
	var max_steps: int = ceili(fade_radius)

	for step in range(1, max_steps + 1):
		var y_up: int = coordinates.y - step
		var y_down: int = coordinates.y + step
		var x_left: int = coordinates.x - step
		var x_right: int = coordinates.x + step

		for x in range(x_left, x_right + 1):
			if grid_map.has(Vector2i(x, y_up)):
				return grid_map.get(Vector2i(x, y_up))
			if grid_map.has(Vector2i(x, y_down)):
				return grid_map.get(Vector2i(x, y_down))

		for y in range(y_up + 1, y_down):
			if grid_map.has(Vector2i(x_left, y)):
				return grid_map.get(Vector2i(x_left, y))
			if grid_map.has(Vector2i(x_right, y)):
				return grid_map.get(Vector2i(x_right, y))

	return null

enum NeighborFilter {ORTHOGONAL, DIAGONAL, OMNIDIRECTIONAL}

func get_neighbors(coordinates: Vector2i, filter: NeighborFilter = NeighborFilter.ORTHOGONAL) -> Array[GridItem]:
	var neighbors: Array[GridItem] = []
	if grid.is_empty(): return neighbors

	var y_up: int = coordinates.y - 1
	var y_down: int = coordinates.y + 1
	var x_left: int = coordinates.x - 1
	var x_right: int = coordinates.x + 1

	var include_orthogonals: bool = filter != NeighborFilter.DIAGONAL
	var include_diagonals: bool = filter != NeighborFilter.ORTHOGONAL

	var neighbor_coordinates: Array[Vector2i] = []

	if include_orthogonals:
		neighbor_coordinates.append(Vector2i(x_left, coordinates.y))

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_left, y_up))
	
	if include_orthogonals:
		neighbor_coordinates.append(Vector2i(coordinates.x, y_up))

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_right, y_up))
	
	if include_orthogonals:
		neighbor_coordinates.append(Vector2i(x_right, coordinates.y))

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_right, y_down))

	if include_orthogonals:
		neighbor_coordinates.append(Vector2i(coordinates.x, y_down))

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_left, y_down))

	for neighbor_coordinate in neighbor_coordinates:
		if grid_map.has(neighbor_coordinate):
			neighbors.append(grid_map.get(neighbor_coordinate))

	return neighbors

func update_instance_opacity(index: int, coordinates: Vector2) -> void:
	var closest_item: GridItem = get_closest_item(coordinates)
	var closest_item_coordinates: Vector2 = closest_item.coordinates if closest_item else Vector2i(center)
	var quad_opacity: float = 0.0
		
	if not closest_item or closest_item_coordinates != coordinates:
		quad_opacity = clampf(1.0 - coordinates.distance_to(closest_item_coordinates) / fade_radius, 0.33, 1.0) * opacity

	multimesh.set_instance_color(index, Color(1.0, 1.0, 1.0, quad_opacity))

var is_rendering: bool = false
var next_chunk_coordinates: Vector2i = Vector2i.ZERO
func process_render() -> void:
	if not is_rendering: return

func render() -> void:
	var index: int = 0
	var grid_item_size: Vector2 = get_grid_item_size()

	for y in grid_size.y: for x in grid_size.x:
		var coordinates: Vector2 = Vector2(x, y)
		var instance_transform: Transform2D = Transform2D(0.0, coordinates * grid_item_size)

		multimesh.set_instance_transform_2d(index, instance_transform)
		update_instance_opacity(index, coordinates)
		index += 1

	multimesh_instance.position = get_grid_position()
	
func render_around(coordinates: Vector2i) -> void:
	var radius: int = ceili(fade_radius)

	for y in range(coordinates.y - radius, coordinates.y + radius + 1):
		for x in range(coordinates.x - radius, coordinates.x + radius + 1):
			if x < 0 or x >= grid_size.x or y < 0 or y >= grid_size.y: continue
			var index: int = y * grid_size.x + x
			update_instance_opacity(index, Vector2(x, y))
		
func build() -> void:
	if multimesh_instance: return
	var grid_item_size: Vector2 = get_grid_item_size()
	var atlas_size: Vector2 = texture.atlas.get_size()

	var shader_material: ShaderMaterial = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("region_offset", texture.region.position / atlas_size)
	shader_material.set_shader_parameter("region_size", texture.region.size / atlas_size)

	multimesh_instance = MultiMeshInstance2D.new()
	multimesh_instance.texture = texture.atlas
	multimesh_instance.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	multimesh_instance.material = shader_material
	add_child(multimesh_instance)

	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = grid_item_size

	if multimesh: multimesh.queue_free()

	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.mesh = mesh
	multimesh.instance_count = grid_size.x * grid_size.y

	multimesh_instance.multimesh = multimesh
	render()

func has_item(coordinates: Vector2i) -> bool:
	return grid_map.has(coordinates)

func add_item(item: GridItem, coordinates: Vector2i) -> void:
	item.coordinates = coordinates
	item.grid = self

	grid.append(item)
	grid_map.set(coordinates, item)

	add_child(item)
	item.position = get_grid_item_position(coordinates)

	render_around(coordinates)

func move_item(item: GridItem, coordinates: Vector2i) -> bool:
	if not grid.has(item): return false

	var old_coordinates: Vector2i = item.coordinates
	var conflicting_item: GridItem = grid_map.get(coordinates)

	grid_map.erase(old_coordinates)
	item.coordinates = coordinates
	grid_map.set(coordinates, item)
	item.animate_position(get_grid_item_position(coordinates), 0.1)

	if conflicting_item:
		conflicting_item.coordinates = old_coordinates
		grid_map.set(old_coordinates, conflicting_item)
		conflicting_item.animate_position(get_grid_item_position(old_coordinates))

	render_around(coordinates)
	render_around(old_coordinates)

	return true

func _ready() -> void:
	center = (Vector2(grid_size) - Vector2.ONE) * 0.5
	Game.grid = self

	var viewport: Viewport = get_viewport()
	var camera: Camera2D = viewport.get_camera_2d()
	var zoom: Vector2 = Vector2.ONE * Global.game_scale
	
	if camera: zoom = camera.zoom
	
	var viewport_size: Vector2i = viewport.size
	position = (viewport_size * 0.5) / zoom
	
	build()
