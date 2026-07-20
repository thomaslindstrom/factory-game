@tool
extends StateBehavior

@export var score: int = 1

func enter() -> void:
	Game.score += score
