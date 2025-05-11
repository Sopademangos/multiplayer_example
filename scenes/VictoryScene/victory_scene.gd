extends Control

@onready var retry: Button = $GridContainer/Retry
@onready var quit: Button = $GridContainer/Quit
@onready var lose: Label = $lose
@onready var win: Label = $win

func _ready() -> void:
	retry.connect("pressed", _on_retry_pressed)
	quit.connect("pressed", _on_quit_pressed)
	# Si Jugador2 tiene rol Hero, entonces desactiva el label de win de Jugador1
	if Game.players[1].role == 1:
		set_multiplayer_authority(Game.players[1].id)
		_activated()
	else:
		set_multiplayer_authority(Game.players[0].id)
		_activated()

func _activated():
	lose.visible = false
	if multiplayer.get_unique_id() != 1:
		win.visible = false
		lose.visible = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	FloorManager.load_random_floor()

func _on_quit_pressed() -> void:
	get_tree().quit()
