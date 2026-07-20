@tool
extends Node
class_name GridDebugger

@export var grid: Grid
@export var items: Array[GridItemResource] = []

@export_tool_button("Render") var button_render: Callable = render

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not grid: warnings.append("`grid` is not set")
	return warnings

func render() -> void:
	if not grid: return
	grid.clear()

	for item_resource in items:
		var item_instance: GridItem = item_resource.create()
		if not item_instance: continue

		if grid.has_item(item_resource.coordinates):
			push_error("Item already occupies coordinates: %s" % item_resource.coordinates)
			continue
			
		grid.add_item(item_instance, item_resource.coordinates)

func _ready() -> void:
	render()
