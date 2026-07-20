extends Node2D
class_name GridItem

var grid: Grid
var coordinates: Vector2i
var content: GridItemContent

func _ready() -> void:
	if not content: return
	add_child(content)

func _init(input_content: GridItemContent) -> void:
	self.content = input_content

# TODO movement and drag and drop logic etc
