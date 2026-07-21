@tool
extends Node

var ui_scale: float = 3.0
var game_scale: float = 1.0

## Returns a banded smoothstep value between `start` and `end`, where values less than `start` or greater than `end` is 0.0, and 1.0 if the value is between `band_start` and `band_end`. For example: `smoothstep_band(0.2, 0.4, 0.6, 0.8, 0.9) = 0.0`, `smoothstep_band(0.2, 0.4, 0.6, 0.8, 0.5) = 1.0`
func smoothstep_band(start: float, band_start: float, band_end: float, end: float, value: float) -> float:
	if value < start or value > end: return 0.0
	if value < band_start: return smoothstep(start, band_start, value)
	if value > band_end: return 1.0 - smoothstep(band_end, end, value)

	return 1.0

## Creates a timer and waits for it to finish
func timer(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
