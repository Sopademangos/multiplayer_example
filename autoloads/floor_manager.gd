extends Node

#signal floor_completed
#signal floor_changed(floor_index: int)

var floor_scenes = {
	1: [
		"res://scenes/levels/level1/level1_1.tscn",
		"res://scenes/levels/level1/level1_2.tscn",
		"res://scenes/levels/level1/level1_3.tscn"
	],
	2: [
		"res://scenes/levels/level2/level2_1.tscn",
		"res://scenes/levels/level2/level2_2.tscn",
		"res://scenes/levels/level2/level2_3.tscn"
	],
	3: [
		"res://scenes/levels/level3/level3_1.tscn",
		"res://scenes/levels/level3/level3_2.tscn",
		"res://scenes/levels/level3/level3_3.tscn"
	],
	4: [
		"res://scenes/levels/level_boss/level_boss.tscn",
		"res://scenes/levels/level_boss/level_boss.tscn",
		"res://scenes/levels/level_boss/level_boss.tscn"
	]
}

var levels_to_play = []

var current_floor: int = 1
var enemies_remaining = 0
var is_changing_floor = false

func _ready():
	await get_tree().process_frame 
	if multiplayer.is_server():  # Solo el host real
		generate_levels.rpc()

@rpc("any_peer", "call_local", "reliable")
func generate_levels():
	if multiplayer.is_server():  # Solo el host real
		randomize()
		var current_floor_index = 1
		for i in range(floor_scenes.size()):
			var random_index = randi() % 3
			levels_to_play.append(floor_scenes[current_floor_index][random_index])
			current_floor_index += 1

# Called by villain when spawning an enemy (server only)
func enemy_spawned():
	enemies_remaining += 1
	print("Enemy spawned. Remaining: ", enemies_remaining)

# Called when an enemy is defeated
func enemy_defeated():
	if !is_changing_floor:
		enemies_remaining -= 1
		print("Enemy defeated. Remaining: ", enemies_remaining)
		if enemies_remaining <= 0:
			await get_tree().create_timer(1.5).timeout
			if levels_to_play.size() > 0:
				_heros_victory.rpc()
			else:
				_run_ended.rpc()
			return true
		else:
			return false

# Called when the hero is defeated
func hero_defeated():
	if !is_changing_floor:
		await get_tree().create_timer(1.5).timeout
		if levels_to_play.size() > 0:
			_villains_victory.rpc()
		else:
			_run_ended.rpc()

func _continue():
	delete_current_scene.rpc()

@rpc("any_peer", "call_local", "reliable")
func delete_current_scene():
	current_floor += 1
	get_tree().current_scene.get_child(1).queue_free()
	_on_floor_completed()
	var root = get_tree().current_scene
	var ui = root.get_child(0)
	var victory_scene = ui.get_child(1)
	var death_scene = ui.get_child(0)
	victory_scene.visible = false
	death_scene.visible = false

# Load a specific floor
@rpc("any_peer", "call_local", "reliable")
func load_specific_floor():
	if !is_changing_floor:
		var root = get_tree().current_scene
		is_changing_floor = true
		
		enemies_remaining = 0  # Reset enemy count on server only
		var scene_path = levels_to_play.pop_front()
		
		var scene_resource = load(scene_path)
		var instance = scene_resource.instantiate()
		if root.name == "World":
			root.add_child(instance)
		
		# Allow a moment for the scene to load before emitting signal
		await get_tree().process_frame
		is_changing_floor = false
		
		# Wait for scene to be ready before repositioning players
		get_tree().node_added.connect(func(node): 
			if node is Node2D and node.name == "World":
				await get_tree().process_frame
				reposition_players()
		)

# Reposition players to their spawn points
func reposition_players():
	var root = get_tree().current_scene
	if not root:
		return
	
	var spawns = root.get_node_or_null("Spawns")
	var players = root.get_node_or_null("Players")
	
	if spawns and players and spawns.get_child_count() >= 1 and players.get_child_count() >= 2:
		var _hero = players.get_node_or_null("Hero")
		
		if _hero and spawns.get_child_count() > 0:
			_hero.global_position = spawns.get_child(0).global_position

# Handle floor completion (server only)
func _on_floor_completed():
	if multiplayer.is_server():
		load_specific_floor.rpc()

@rpc("any_peer", "call_local", "reliable")
func _heros_victory() -> void:
	var root = get_tree().current_scene
	var ui = root.get_child(0)
	var victory_scene = ui.get_child(1)
	victory_scene.elegir_cartas_aleatorias()
	victory_scene.visible = true
	var animation_victory_scene = victory_scene.get_child(1)
	animation_victory_scene.play("fade_in")

@rpc("any_peer", "call_local", "reliable")
func _villains_victory() -> void:
	var root = get_tree().current_scene
	var ui = root.get_child(0)
	var death_scene = ui.get_child(0)
	death_scene.elegir_cartas_aleatorias()
	death_scene.visible = true
	var animation_death_scene = death_scene.get_child(1)
	animation_death_scene.play("fade_in")

@rpc("any_peer", "call_local", "reliable")
func _run_ended(): #Terminamos la partida y volvemos al menu
	GlobalVar.creditos = true
	get_tree().change_scene_to_file("res://ui/credits.tscn")
