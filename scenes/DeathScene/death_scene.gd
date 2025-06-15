extends Control

@onready var retry: Button = $GridContainer/Retry
@onready var quit: Button = $GridContainer/Quit
@onready var lose: Label = $lose
@onready var win: Label = $win

func _ready() -> void:
	retry.connect("pressed", _on_retry_pressed)
	quit.connect("pressed", _on_quit_pressed)
	
	if Game.players[0].role == 1:
		_activated.rpc(true)
	else:
		_activated.rpc(false)

#Activa el label de win del player que maneja al villano
@rpc("any_peer", "call_local", "reliable")
func _activated(player1: bool):
	if player1:
		if multiplayer.get_unique_id() == 1:
			lose.visible = true
		else:
			win.visible = true
	else:
		if multiplayer.get_unique_id() == 1:
			win.visible = true
		else:
			lose.visible = true

func _on_retry_pressed() -> void:
	# Devuelve una lista de los peer_ids de todos los jugadores conectados
	var players_connected = multiplayer.get_peers()
	if multiplayer.is_server():
		_retry()
		_reload_scene.rpc_id(players_connected[0])
	else:
		_retry.rpc_id(1)
		get_tree().reload_current_scene()

# Si quitamos esto permite que ambos players deban querer jugar de nuevo para que funcione
@rpc("any_peer","call_local", "reliable")
func _retry():
	FloorManager.current_floor = 1
	FloorManager.enemies_remaining = 0
	FloorManager.levels_to_play = []
	FloorManager.generate_levels()
	get_tree().reload_current_scene()

@rpc("any_peer","call_local", "reliable")
func _reload_scene():
	FloorManager.current_floor = 1
	FloorManager.enemies_remaining = 0
	FloorManager.levels_to_play = []
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
