extends NinePatchRect

# TODO more robust system with array with callables and IDs?

func handle_mouse_entered() -> void:
	Game.is_shop_drop_valid = false

func handle_mouse_exited() -> void:
	Game.is_shop_drop_valid = true

func _ready() -> void:
	mouse_entered.connect(handle_mouse_entered.call_deferred)
	mouse_exited.connect(handle_mouse_exited.call_deferred)
