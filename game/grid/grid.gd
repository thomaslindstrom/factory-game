@tool
extends Node2D
class_name Grid

@export var grid_size: Vector2i = Vector2i(512, 512)
@export var texture: AtlasTexture
@export var shader: Shader
@export var opacity: float = 0.25
@export var fade_radius: float = 5.0
@export var render_chunk_size: int = 32

var grid: Array[GridItem] = []
var grid_map: Dictionary[Vector2i, GridItem] = {}
var grid_item_size: Vector2 = Vector2.ZERO
var center: Vector2 = Vector2.ZERO
var center_vector2i: Vector2i = Vector2i.ZERO

func get_mouse_position() -> Vector2:
	return get_global_mouse_position()

func get_grid_position() -> Vector2:
	return -center * grid_item_size

func coordinates_to_position(coordinates: Vector2i) -> Vector2:
	return get_grid_position() + (Vector2(coordinates) * grid_item_size)

func global_position_to_coordinates(input_global_position: Vector2) -> Vector2i:
	return ((to_local(input_global_position) - get_grid_position()) / grid_item_size + Vector2.ONE * 0.5).clamp(Vector2.ZERO, Vector2(grid_size) - Vector2.ONE)

func are_coordinates_valid(coordinates: Vector2i) -> bool:
	return coordinates.x >= 0 and coordinates.x < grid_size.x and coordinates.y >= 0 and coordinates.y < grid_size.y

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
	if grid_map.is_empty(): return null
	if grid_map.has(coordinates): return grid_map.get(coordinates)

	var max_steps: int = ceili(fade_radius)

	for step in range(1, max_steps + 1):
		var y_up: int = coordinates.y - step
		var y_down: int = coordinates.y + step
		var x_left: int = coordinates.x - step
		var x_right: int = coordinates.x + step

		for x in range(x_left, x_right + 1):
			var up: Vector2i = Vector2i(x, y_up)
			if grid_map.has(up): return grid_map.get(up)
			var down: Vector2i = Vector2i(x, y_down)
			if grid_map.has(down): return grid_map.get(down)

		for y in range(y_up + 1, y_down):
			var left: Vector2i = Vector2i(x_left, y)
			if grid_map.has(left): return grid_map.get(left)
			var right: Vector2i = Vector2i(x_right, y)
			if grid_map.has(right): return grid_map.get(right)

	return null

func get_focused_coordinates() -> Array[Vector2i]:
	var focused_coordinates: Array[Vector2i] = [center_vector2i]

	if not Engine.is_editor_hint():
		if Game.is_grid_drop_valid and Game.grid_drop_coordinates:
			focused_coordinates.append(Game.grid_drop_coordinates)
		if Game.is_shop_drop_valid and Game.shop_drop_coordinates:
			focused_coordinates.append(Game.shop_drop_coordinates)

	return focused_coordinates

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

func update_instance_transform(index: int, coordinates: Vector2i) -> void:
	var instance_transform: Transform2D = Transform2D(0.0, Vector2(coordinates) * grid_item_size)
	multimesh.set_instance_transform_2d(index, instance_transform)

var color_white_transparent: Color = Color(1.0, 1.0, 1.0, 0.0)

func update_instance_opacity(index: int, coordinates: Vector2i, focused_coordinates: Array[Vector2i]) -> void:
	if grid_map.has(coordinates):
		multimesh.set_instance_color(index, color_white_transparent)
		return

	var closest_distance: float = INF

	for active_coordinate in focused_coordinates:
		var distance: float = coordinates.distance_squared_to(active_coordinate)
		if distance < closest_distance: closest_distance = distance

	var closest_item: GridItem = get_closest_item(coordinates)
	
	if closest_item:
		var distance: float = closest_item.coordinates.distance_squared_to(coordinates)
		if distance < closest_distance: closest_distance = distance

	var closest_distance_squared: float = sqrt(closest_distance)
	var quad_opacity: float = clampf(1.0 - closest_distance_squared / fade_radius, 0.33, 1.0) * opacity
	multimesh.set_instance_color(index, Color(1.0, 1.0, 1.0, quad_opacity))

var is_rendering: bool = false
var render_iteration: int = 0
func process_render() -> void:
	if not is_rendering: return

	var total_cells: int = grid_size.x * grid_size.y
	var cells_per_frame: int = render_chunk_size * render_chunk_size
	var start: int = render_iteration * cells_per_frame
	var end: int = mini(start + cells_per_frame, total_cells)

	var focused_coordinates: Array[Vector2i] = get_focused_coordinates()

	for index in range(start, end):
		var coordinates: Vector2i = Vector2i(index % grid_size.x, index / grid_size.x)
		update_instance_transform(index, coordinates)
		update_instance_opacity(index, coordinates, focused_coordinates)

	if end >= total_cells:
		is_rendering = false
		render_iteration = 0
	else: render_iteration += 1

func queue_render() -> void:
	is_rendering = true

func render() -> void:
	var focused_coordinates: Array[Vector2i] = get_focused_coordinates()
	var index: int = 0

	for y in grid_size.y: for x in grid_size.x:
		var coordinates: Vector2i = Vector2i(x, y)
		update_instance_transform(index, coordinates)
		update_instance_opacity(index, coordinates, focused_coordinates)
		index += 1
	
var previous_render_around_coordinates: Vector2i
func render_around(coordinates: Vector2i, force: bool = false) -> void:
	if not force and previous_render_around_coordinates == coordinates: return
	previous_render_around_coordinates = coordinates

	var radius: int = ceili(fade_radius)
	var focused_coordinates: Array[Vector2i] = get_focused_coordinates()
	var start_x: int = maxi(coordinates.x - radius, 0)
	var end_x: int = mini(coordinates.x + radius, grid_size.x - 1)
	var start_y: int = maxi(coordinates.y - radius, 0)
	var end_y: int = mini(coordinates.y + radius, grid_size.y - 1)

	for y in range(start_y, end_y + 1): for x in range(start_x, end_x + 1):
		var index: int = y * grid_size.x + x
		update_instance_opacity(index, Vector2i(x, y), focused_coordinates)
		
func build() -> void:
	if multimesh_instance: return
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

	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.mesh = mesh
	multimesh.instance_count = grid_size.x * grid_size.y

	multimesh_instance.multimesh = multimesh
	multimesh_instance.position = get_grid_position()
	queue_render()

func has_item(coordinates: Vector2i) -> bool:
	return grid_map.has(coordinates)

func add_item(item: GridItem, coordinates: Vector2i) -> void:
	item.coordinates = coordinates
	item.grid = self

	grid.append(item)
	grid_map.set(coordinates, item)

	add_child(item)
	item.position = coordinates_to_position(coordinates)

	render_around(coordinates)

func move_item(item: GridItem, coordinates: Vector2i) -> bool:
	if not grid.has(item): return false

	var old_coordinates: Vector2i = item.coordinates
	var conflicting_item: GridItem = grid_map.get(coordinates)

	grid_map.erase(old_coordinates)
	item.coordinates = coordinates
	grid_map.set(coordinates, item)
	item.animate_position(coordinates_to_position(coordinates), 0.1)

	if conflicting_item:
		conflicting_item.coordinates = old_coordinates
		grid_map.set(old_coordinates, conflicting_item)
		conflicting_item.animate_position(coordinates_to_position(old_coordinates))

	render_around(coordinates)
	render_around(old_coordinates)

	return true

func handle_grid_drop_hover(_item: GridItem) -> void:
	render_around(Game.previous_grid_drop_coordinates)
	render_around(Game.grid_drop_coordinates)

func handle_grid_drop_hover_end() -> void:
	render_around(Game.previous_grid_drop_coordinates, true)

func handle_shop_drop_hover(_item: ShopItemResource) -> void:
	render_around(Game.previous_shop_drop_coordinates)
	render_around(Game.shop_drop_coordinates)

func handle_shop_drop_hover_end() -> void:
	render_around(Game.previous_shop_drop_coordinates, true)

func _ready() -> void:
	grid_item_size = texture.region.size
	center = (Vector2(grid_size) - Vector2.ONE) * 0.5
	center_vector2i = Vector2i(center)

	if not Engine.is_editor_hint():
		Game.grid = self
		Game.on_grid_drop_hover.connect(handle_grid_drop_hover)
		Game.on_grid_drop_hover_end.connect(handle_grid_drop_hover_end)
		Game.on_shop_drop_hover.connect(handle_shop_drop_hover)
		Game.on_shop_drop_hover_end.connect(handle_shop_drop_hover_end.call_deferred)

	var viewport: Viewport = get_viewport()
	var camera: Camera2D = viewport.get_camera_2d()
	var zoom: Vector2 = Vector2.ONE * Global.game_scale
	
	if camera: zoom = camera.zoom
	
	var viewport_size: Vector2i = viewport.size
	position = (viewport_size * 0.5) / zoom
	
	build()

func _physics_process(_delta: float) -> void:
	process_render()
