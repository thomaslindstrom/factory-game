@tool
extends SubViewportCamera

@export_range(100.0, 1000.0, 100.0) var pan_speed: float = 400.0
@export_range(0.01, 1.0, 0.01) var zoom_speed: float = 0.4
@export var minimum_zoom: float = 1.0
@export var maximum_zoom: float = 5.0

var zoom_target: float = Global.initial_game_zoom_target

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		position += direction * pan_speed * delta / zoom.x

	var is_zoom_in_pressed: bool = Input.is_action_pressed("zoom_in")
	var is_zoom_out_pressed: bool = Input.is_action_pressed("zoom_out")
	var zoom_direction: float = 1.0 if is_zoom_in_pressed else -1.0 if is_zoom_out_pressed else 0.0

	if zoom_direction != 0.0:
		zoom_target = clampf(zoom.x + zoom_direction * zoom_speed, minimum_zoom, maximum_zoom)

	if zoom_target != zoom.x:
		zoom = zoom.lerp(Vector2(zoom_target, zoom_target), delta * 10.0)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	var viewport: Viewport = get_viewport()
	var viewport_size: Vector2i = viewport.size

	position = (viewport_size * 0.5) / zoom
	reset_smoothing()
