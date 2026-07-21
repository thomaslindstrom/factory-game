@tool
extends Camera2D
class_name SubViewportCamera

enum CameraType {GAME, UI}
@export var camera_type: CameraType = CameraType.GAME

func _ready() -> void:
	# UI scale is applied by resizing the SubViewport (see ui_viewport_camera.gd),
	# so Control anchors stay in logical pixel space. Only the game camera uses zoom.
	var initial_zoom: float = Global.game_scale if camera_type == CameraType.GAME else 1.0
	var wanted_zoom: Vector2 = Vector2.ONE * initial_zoom
	if zoom != wanted_zoom: zoom = wanted_zoom
