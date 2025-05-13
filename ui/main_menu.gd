class_name MainMenu
extends Control


@onready var host: Button = %Host
@onready var join: Button = %Join
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit


func _ready() -> void:
	#if Game.multiplayer_test:
		#get_tree().change_scene_to_file("res://lobby/lobby_test.tscn")
		#return
	
	quit.pressed.connect(func(): get_tree().quit())
	host.pressed.connect(func(): 
		get_tree().change_scene_to_file("res://lobby/host_screen.tscn")
	)
	join.pressed.connect(func(): get_tree().change_scene_to_file("res://lobby/join_screen.tscn"))
	credits.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/credits.tscn"))
	
	host.grab_focus()

# Also add this to lobby_test.gd - modify the _on_start_game_timeout function:
func _on_start_game_timeout() -> void:
	_start_game.rpc()

@rpc("reliable", "call_local")
func _start_game() -> void:
	# Start with a random floor instead of loading the main scene directly
	FloorManager.start_game()
