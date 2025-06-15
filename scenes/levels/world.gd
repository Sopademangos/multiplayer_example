extends Node2D

var change_floor: bool = false

func _ready():
	if !multiplayer.is_server():
		client_ready.rpc_id(1) # Server es peer_id 1

@rpc("any_peer", "reliable")
func client_ready():
	if multiplayer.is_server():
		send_levels.rpc(FloorManager.levels_to_play)

@rpc("authority", "call_local", "reliable")
func send_levels(levels):
	FloorManager.levels_to_play = levels.duplicate()
	await get_tree().create_timer(0.5).timeout
	load_current_level()

func load_current_level():
	if !change_floor and FloorManager.levels_to_play.size() > 0:
		var current_level = FloorManager.levels_to_play.pop_front()
		var scene_load = load(current_level)
		if scene_load:
			var instance = scene_load.instantiate()
			add_child(instance)
			print("Cargando escena: ", current_level)
		else:
			print("Error: No se pudo cargar la escena ", current_level)
		change_floor = true
		await get_tree().process_frame
		change_floor = false
	else:
		print("No hay niveles o se está cambiando de piso.")
