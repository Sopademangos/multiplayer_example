extends Node

signal floor_completed
signal floor_changed(floor_index: int)

# Array of floor scene paths - You'll need to create these floor scenes
var floor_scenes = [
	"res://scenes/levels/test.tscn",
]

var current_floor_index = 0
var enemies_remaining = 0
var is_changing_floor = false

func _ready():
	floor_completed.connect(_on_floor_completed)
	# Wait for scene to be ready before repositioning players
	get_tree().node_added.connect(func(node): 
		if node is Node2D and node.name == "World":
			await get_tree().process_frame
			reposition_players()
	)

# Start the game with a random floor
func start_game():
	randomize()  # Initialize random number generator
	if multiplayer.is_server():
		load_random_floor()

# Called by villain when spawning an enemy (server only)
func enemy_spawned():
	if multiplayer.is_server():
		enemies_remaining += 1
		print("Enemy spawned. Remaining: ", enemies_remaining)

# Called when an enemy is defeated (server only)
func enemy_defeated():
	if multiplayer.is_server() and !is_changing_floor:
		enemies_remaining -= 1
		print("Enemy defeated. Remaining: ", enemies_remaining)
		if enemies_remaining <= 0:
			floor_completed.emit()

# Load a random floor scene (server only)
func load_random_floor():
	if multiplayer.is_server():
		var random_index = randi() % floor_scenes.size()
		load_specific_floor.rpc(random_index)

# Load a specific floor by index
@rpc("reliable", "call_local")
func load_specific_floor(floor_index: int):
	is_changing_floor = true
	current_floor_index = floor_index
	
	if multiplayer.is_server():
		enemies_remaining = 0  # Reset enemy count on server only
	
	var scene_path = floor_scenes[floor_index]
	get_tree().change_scene_to_file(scene_path)
	
	# Allow a moment for the scene to load before emitting signal
	await get_tree().process_frame
	is_changing_floor = false
	floor_changed.emit(floor_index)

# Reposition players to their spawn points
func reposition_players():
	var root = get_tree().current_scene
	if not root:
		return
		
	var spawns = root.get_node_or_null("Spawns")
	var players = root.get_node_or_null("Players")
	
	if spawns and players and spawns.get_child_count() >= 2 and players.get_child_count() >= 2:
		var hero = players.get_node_or_null("Hero")
		var villain = players.get_node_or_null("Villian")
		
		if hero and spawns.get_child_count() > 0:
			hero.global_position = spawns.get_child(0).global_position
		


# Handle floor completion (server only)
func _on_floor_completed():
	if multiplayer.is_server():
		print("Floor completed!")
		# Wait a moment before loading the next floor
		await get_tree().create_timer(2.0).timeout
		load_random_floor()
