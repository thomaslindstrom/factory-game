@tool
extends GridItemContent
class_name GridItemContentActivator

@export var neighbor_filter: Grid.NeighborFilter = Grid.NeighborFilter.ORTHOGONAL

@onready var orthogonal: Sprite2D = %Orthogonal
@onready var diagonal: Sprite2D = %Diagonal

func _ready() -> void:
	super._ready()
	
	var show_orthogonal: bool = neighbor_filter != Grid.NeighborFilter.DIAGONAL
	var show_diagonal: bool = neighbor_filter != Grid.NeighborFilter.ORTHOGONAL

	orthogonal.visible = show_orthogonal
	diagonal.visible = show_diagonal
