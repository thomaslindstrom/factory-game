@tool
extends StateFallback

@export_range(0.0, 5.0, 0.1) var delay: float = 2.5

static var count: int = 1
var index: int = 1

func _ready() -> void:
	super._ready()
	index = count
	count += 1

func enter() -> void:
	await Global.timer(index * (delay / count))
	deactivate(false)
	
