@tool
extends Resource
class_name GridItemResource

@export var coordinates: Vector2i = Vector2i.ZERO
@export var content: GridItemContentResource

## Create a new GridItem from this resource
func create() -> GridItem:
	if not content: return null

	var content_instance = content.create()
	var item_instance: GridItem = GridItem.new(content_instance)
	item_instance.coordinates = coordinates
	content_instance.item = item_instance
	
	return item_instance
