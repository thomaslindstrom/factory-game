extends Node

signal on_score_changed(score: int)
var score: int = 0: 
	set(value):
		score = value
		on_score_changed.emit(score)
