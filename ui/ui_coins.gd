@tool
extends UiText
class_name UiCoins

func update(coins: int):
	text = str(coins)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Game.on_coins_changed.connect(update)
	update(Game.coins)
