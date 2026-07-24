@tool
extends StateBehavior

@export var coins: int = 1

func enter() -> void:
	Game.coins += coins
