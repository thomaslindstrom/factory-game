@tool
extends Resource
class_name GridItemContentResource

@export var name: String
@export var scene: PackedScene
@export var can_activate: bool = false
@export var groups: Array[String] = []

## Create a new GridItemContent from this resource
func create() -> GridItemContent:
	var scene_instance: GridItemContent = scene.instantiate()
	scene_instance.resource = self
	return scene_instance
