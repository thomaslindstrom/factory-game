@tool
extends GridItemContent
class_name GridItemContentActivator

@export var neighbor_filter: Grid.NeighborFilter = Grid.NeighborFilter.ORTHOGONAL
@export_range(0.0, 5.0, 0.1) var cooldown_duration: float = 2.0

@onready var orthogonal: Sprite2D = %Orthogonal
@onready var diagonal: Sprite2D = %Diagonal
@onready var active_state: StateBehaviorDuration = %Active

func _ready() -> void:
	super._ready()
	
	var show_orthogonal: bool = neighbor_filter != Grid.NeighborFilter.DIAGONAL
	var show_diagonal: bool = neighbor_filter != Grid.NeighborFilter.ORTHOGONAL

	orthogonal.visible = show_orthogonal
	diagonal.visible = show_diagonal
	active_state.duration = cooldown_duration
