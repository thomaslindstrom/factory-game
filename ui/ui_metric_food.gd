@tool
extends UiMetric
class_name UiMetricFood

func update(food: int):
	text = str(food)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Game.on_food_changed.connect(update)
	update(Game.food)
