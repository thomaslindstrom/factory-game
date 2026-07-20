@tool
extends UiText

func update(score: int):
	text = str(score)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Game.on_score_changed.connect(update)
	update(Game.score)
