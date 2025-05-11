extends Control

var pause = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_pause_game.rpc()

@rpc("any_peer", "call_local", "reliable")
func _pause_game():
	pause = !pause
	visible = pause
	get_tree().paused = pause
