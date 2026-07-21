@tool
extends SubViewportCamera

var ui_viewport: SubViewport
var viewport_container: SubViewportContainer

func apply_display_scale() -> void:
	if not viewport_container or not ui_viewport: return

	var parent: Control = viewport_container.get_parent() as Control
	if not parent: return

	var base_size: Vector2 = parent.size
	if base_size.x < 1.0 or base_size.y < 1.0: return

	var current_scale: float = maxf(Global.ui_scale, 0.01)
	var viewport_size: Vector2i = Vector2i(
		maxi(1, roundi(base_size.x / current_scale)),
		maxi(1, roundi(base_size.y / current_scale)),
	)

	ui_viewport.size = viewport_size
	viewport_container.size = Vector2(viewport_size)
	viewport_container.scale = base_size / Vector2(viewport_size)
	viewport_container.position = Vector2.ZERO

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	ui_viewport = get_parent()
	viewport_container = ui_viewport.get_parent()

	viewport_container.stretch = false
	viewport_container.anchor_right = 0.0
	viewport_container.anchor_bottom = 0.0
	viewport_container.offset_right = 0.0
	viewport_container.offset_bottom = 0.0
	viewport_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	viewport_container.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var parent: Control = viewport_container.get_parent()
	if parent: parent.resized.connect(apply_display_scale)

	apply_display_scale()
