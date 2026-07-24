@tool
extends SubViewportCamera

@export_range(100.0, 1000.0, 100.0) var pan_speed: float = 400.0
@export_range(0.1, 5.0, 0.1) var zoom_speed: float = 2.5
@export_range(1.0, 20.0, 0.5) var zoom_lerp_speed: float = 12.0
@export_range(0.01, 1.0, 0.01) var zoom_modifier_multiplier: float = 0.5
@export var minimum_zoom: float = 1.0
@export var maximum_zoom: float = 5.0

var zoom_target: float = 6.0
var display_zoom: float = 6.0

var game_viewport: SubViewport
var viewport_container: SubViewportContainer

func apply_display_zoom() -> void:
	if not viewport_container or not game_viewport: return

	var parent: Control = viewport_container.get_parent() as Control
	if not parent: return

	var base_size: Vector2 = parent.size
	if base_size.x < 1.0 or base_size.y < 1.0: return

	var current_zoom: float = maxf(display_zoom, 0.01)
	var viewport_size: Vector2i = Vector2i(
		maxi(1, roundi(base_size.x / current_zoom)),
		maxi(1, roundi(base_size.y / current_zoom)),
	)

	game_viewport.size = viewport_size
	viewport_container.size = Vector2(viewport_size)
	viewport_container.scale = base_size / Vector2(viewport_size)
	viewport_container.position = Vector2.ZERO

func reset_position() -> void:
	position = (Game.grid.global_position if Game.grid else Vector2.ZERO) + Vector2(0.1, 0.1)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	var is_zoom_in_pressed: bool = Input.is_action_pressed("zoom_in")
	var is_zoom_out_pressed: bool = Input.is_action_pressed("zoom_out")
	var is_modifier_pressed: bool = Input.is_action_pressed("modifier")

	var zoom_direction: float = 1.0 if is_zoom_in_pressed else -1.0 if is_zoom_out_pressed else 0.0
	var is_zooming: bool = zoom_direction != 0.0
	var modifier: float = zoom_modifier_multiplier if is_modifier_pressed else 1.0

	if is_zooming:
		zoom_target = clampf(zoom_target + zoom_direction * zoom_speed * modifier * delta, minimum_zoom, maximum_zoom)

	var zoom_destination: float = zoom_target if is_zooming else clampf(roundf(zoom_target), minimum_zoom, maximum_zoom)

	if not is_equal_approx(display_zoom, zoom_destination):
		display_zoom = lerpf(display_zoom, zoom_destination, 1.0 - exp(-zoom_lerp_speed * modifier * delta))

		if not is_zooming and absf(display_zoom - zoom_destination) < 0.01:
			display_zoom = zoom_destination
			zoom_target = zoom_destination

		apply_display_zoom()

	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		position += direction * pan_speed * modifier * delta / display_zoom

	if position == position.round(): position += Vector2(0.1, 0.1)

	if Input.is_action_just_pressed("tertiary"):
		reset_position()

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	game_viewport = get_parent()
	viewport_container = game_viewport.get_parent()

	viewport_container.stretch = false
	viewport_container.anchor_right = 0.0
	viewport_container.anchor_bottom = 0.0
	viewport_container.offset_right = 0.0
	viewport_container.offset_bottom = 0.0
	viewport_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	viewport_container.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var parent: Control = viewport_container.get_parent() as Control
	if parent: parent.resized.connect(apply_display_zoom)

	display_zoom = zoom_target
	apply_display_zoom()

	position = (Vector2(game_viewport.size) * 0.5).round() + Vector2(0.1, 0.1)
	reset_smoothing()
