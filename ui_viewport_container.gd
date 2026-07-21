extends SubViewportContainer
class_name UiViewportContainer

func _has_point(point: Vector2) -> bool:
	if get_child_count() == 0: return false

	var viewport: SubViewport = get_child(0) as SubViewport
	if not viewport: return false

	return find_blocking_control(viewport, point) != null

func find_blocking_control(node: Node, point: Vector2) -> Control:
	for i in range(node.get_child_count() - 1, -1, -1):
		var child: Node = node.get_child(i)

		if child is Control:
			var hit: Control = find_in_control(child as Control, point)
			if hit: return hit
		elif child.get_child_count() > 0:
			var hit: Control = find_blocking_control(child, point)
			if hit: return hit

	return null

func find_in_control(control: Control, point: Vector2) -> Control:
	if not control.is_visible_in_tree(): return null
	if control.mouse_filter == Control.MOUSE_FILTER_IGNORE: return find_blocking_control(control, point)
	if not control.get_global_rect().has_point(point): return null

	var child_hit: Control = find_blocking_control(control, point)
	if child_hit: return child_hit

	return control
