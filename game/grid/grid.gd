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

func get_grid_item_size() -> Vector2:
	return texture.region.size

func get_grid_center() -> Vector2:
	return (Vector2(grid_size) - Vector2.ONE) * 0.5

func get_grid_position() -> Vector2:
	return -get_grid_center() * get_grid_item_size()

func get_grid_item_position(coordinates: Vector2i) -> Vector2:
	return get_grid_position() + (Vector2(coordinates) * get_grid_item_size())

var multimesh_instance: MultiMeshInstance2D

@export_tool_button("Render") var button_render: Callable = func() -> void:
	if multimesh_instance: multimesh_instance.queue_free()
	multimesh_instance = null
	build()

func clear() -> void:
	for item in grid: item.queue_free()
	grid.clear()
	grid_map.clear()

func get_closest_item(coordinates: Vector2i) -> GridItem:
	if grid.is_empty(): return null
	if grid_map.has(coordinates): return grid_map.get(coordinates)

	var closest_item: GridItem = grid.get(0)
	var closest_item_distance: float = closest_item.coordinates.distance_to(coordinates)

	for item in grid:
		var current_item_distance: float = item.coordinates.distance_to(coordinates)

		if current_item_distance < closest_item_distance:
			closest_item = item
			closest_item_distance = current_item_distance

	return closest_item

func get_neighbors(coordinates: Vector2i, include_diagonals: bool = false) -> Array[GridItem]:
	var neighbors: Array[GridItem] = []
	if grid.is_empty(): return neighbors

	var y_up: int = coordinates.y - 1
	var y_down: int = coordinates.y + 1
	var x_left: int = coordinates.x - 1
	var x_right: int = coordinates.x + 1

	var neighbor_coordinates: Array[Vector2i] = [
		Vector2i(x_left, coordinates.y)
	]

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_left, y_up))
	
	neighbor_coordinates.append(Vector2i(coordinates.x, y_up))

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_right, y_up))
	
	neighbor_coordinates.append(Vector2i(x_right, coordinates.y))

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_right, y_down))

	neighbor_coordinates.append(Vector2i(coordinates.x, y_down))

	if include_diagonals:
		neighbor_coordinates.append(Vector2i(x_left, y_down))

	for neighbor_coordinate in neighbor_coordinates:
		if grid_map.has(neighbor_coordinate):
			neighbors.append(grid_map.get(neighbor_coordinate))

	return neighbors

func render() -> void:
	var index: int = 0
	var multimesh: MultiMesh = multimesh_instance.multimesh
	var grid_item_size: Vector2 = get_grid_item_size()
	var center: Vector2 = get_grid_center()
	var radius: float = maxf(fade_radius, 0.001)

	for y in grid_size.y: for x in grid_size.x:
		var coordinates: Vector2 = Vector2(x, y)
		var closest_item: GridItem = get_closest_item(coordinates)
		var closest_item_coordinates: Vector2 = closest_item.coordinates if closest_item else Vector2i(center)
		var quad_opacity: float = clampf(1.0 - coordinates.distance_to(closest_item_coordinates) / radius, 0.0, 1.0) * opacity

		multimesh.set_instance_transform_2d(
			index,
			Transform2D(0.0, coordinates * grid_item_size)
		)

		multimesh.set_instance_color(index, Color(1.0, 1.0, 1.0, quad_opacity))
		index += 1

	multimesh_instance.position = get_grid_position()
		
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

	var multimesh: MultiMesh = MultiMesh.new()
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

	render()

func _ready() -> void:
	var viewport: Viewport = get_viewport()
	var camera: Camera2D = viewport.get_camera_2d()
	var zoom: Vector2 = Vector2.ONE * Global.initial_game_zoom
	
	if camera: zoom = camera.zoom
	
	var viewport_size: Vector2i = viewport.size
	position = (viewport_size * 0.5) / zoom
	
	build()
