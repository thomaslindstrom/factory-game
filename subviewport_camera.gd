@tool
extends Camera2D
class_name SubViewportCamera

func _init() -> void:
	var wanted_zoom: Vector2 = Vector2.ONE * Global.initial_game_zoom
	if zoom != wanted_zoom: zoom = Vector2.ONE * Global.initial_game_zoom
