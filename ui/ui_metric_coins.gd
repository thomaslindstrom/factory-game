@tool
extends UiMetric
class_name UiMetricCoins

func update(coins: int):
	text = str(coins)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Game.on_coins_changed.connect(update)
	update(Game.coins)
