extends Node2D

@export var hero_scene: PackedScene = preload("res://scenes/hero/hero.tscn")
@export var spawn_distance: float = 100.0

func _ready():
	# Simple debug output
	print("Game world ready. Authority: ", multiplayer.get_unique_id())
	print("Connected players: ", Game.players.size())
	
	# Wait a frame for everything to initialize
	await get_tree().process_frame
	
	# Only server spawns players
	if multiplayer.is_server():
		spawn_players()

func spawn_players():
	print("Spawning players...")
	
	for i in range(Game.players.size()):
		var player_data = Game.players[i]
		var spawn_pos = Vector2(100 + i * spawn_distance, 100)
		
		# Spawn the player on all clients
		spawn_player.rpc(str(player_data.id), player_data.id, spawn_pos)

@rpc("authority", "reliable")
func spawn_player(player_name: String, player_id: int, position: Vector2):
	# Check if player already exists
	if has_node(player_name):
		print("Player already exists:", player_name)
		return
	
	# Create player instance
	var player_instance = hero_scene.instantiate()
	player_instance.name = player_name
	add_child(player_instance)
	
	# Set position and network authority
	player_instance.global_position = position
	player_instance.set_multiplayer_authority(player_id)
	
	# Additional setup if the player has the method
	if player_instance.has_method("setup_multiplayer"):
		player_instance.setup_multiplayer(player_id)
	
	print("Player spawned:", player_name)
