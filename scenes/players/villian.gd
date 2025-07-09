extends Node2D

@onready var enemies_node: Node2D = $"../../Enemies"
var enemy_scene: PackedScene = preload("res://scenes/enemies/enemy.tscn")
@onready var progress_bar: ProgressBar = $TextureProgressBar
@onready var deck: Control = $Deck
@export var fill_time = 36.0 # segundos

var card_dragged = null
var result
var cards = []
var new_card: CardData
const card_scene = preload("res://scenes/cards/card.tscn")

func _ready() -> void:
	if Game.players[1].role == 2:
		set_multiplayer_authority(Game.players[1].id)
		if multiplayer.get_unique_id() == 1:
			visible = false
			for card in deck.get_children():
				card.queue_free()
	else:
		set_multiplayer_authority(Game.players[0].id)
		if multiplayer.get_unique_id() != 1:
			visible = false
			for card in deck.get_children():
				card.queue_free()

var tmp_card = null
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = _check_for_card()
			if card:
				if card == tmp_card:
					card_dragged.scale = Vector2(0.7, 0.7)
					tmp_card = null
					card = null
					card_dragged = null
				else:
					if tmp_card:
						tmp_card.scale = Vector2(0.7, 0.7)
					card_dragged = card
					tmp_card = card
					card_dragged.scale = Vector2(0.75, 0.75)
			else:
				if card_dragged:
					if result.size() < 1 and card_dragged.datos.costo*10 <= progress_bar.value:
						var tmp_speed = card_dragged.datos.velocidad
						var tmp_hp = card_dragged.datos.hp
						var tmp_damage = card_dragged.datos.daño
						if card_dragged.datos.tipo == 1:
							tmp_speed += GlobalVar.enemy_speed_up - GlobalVar.enemy_speed_down
							tmp_hp += GlobalVar.enemy_health_up
							tmp_damage += GlobalVar.enemy_damage_up - GlobalVar.enemy_damage_down
						_spawn_enemy.rpc(
							card_dragged.datos.nombre,
							tmp_speed,
							tmp_hp,
							tmp_damage,
							card_dragged.datos.icono,
							card_dragged.datos.tipo,
							card_dragged.datos.colision,
							card_dragged.datos.radio,
							card_dragged.datos.altura,
							card_dragged.datos.tamaño,
							card_dragged.datos.posicion_colision,
							card_dragged.datos.escala_de_la_figura,
							get_global_mouse_position())
						card_dragged.scale = Vector2(0.7, 0.7)
						progress_bar.value -= card_dragged.datos.costo*10
						card_dragged.modulate = Color(0.23, 0.23, 0.23)
						var tween = create_tween()
						tween.tween_property(card_dragged, "position:y", 162.0+300.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
						robar_carta(card_dragged)
						tmp_card = null
						card = null
						card_dragged = null
					else:
						card_dragged.scale = Vector2(0.7, 0.7)
						tmp_card = null
						card = null
						card_dragged = null

func _process(delta):
	if progress_bar.value < progress_bar.max_value:
		progress_bar.value += ((progress_bar.max_value / fill_time) * 2.5 * delta) + GlobalVar.fill_time_down

@rpc("call_local","reliable")
func _spawn_enemy(nombre: String, velocidad: int, hp: int, daño: int, icono: String, tipo: int, colision: int, radio: float, altura: float, tamaño: Vector2, pos_colision: Vector2, escala_imagen: Vector2, mouse_pos: Vector2):
	var enemy_inst = enemy_scene.instantiate()
	enemy_inst.set_multiplayer_authority(1)
	enemy_inst.position = mouse_pos
	enemies_node.add_child(enemy_inst, true)
	enemy_inst.setup(nombre, velocidad, hp, daño, icono, tipo, colision, radio, altura, tamaño, pos_colision, escala_imagen) # o asignás stats manualmente

func _check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collide_with_bodies = true
	parameters.collision_mask = 3
	result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var hay_colision = false
		for colision in result:
			var col = colision["collider"]
			if col is StaticBody2D or col is CharacterBody2D or col is TileMapLayer or col.name == "Area_daño" or col.name == "Arma":
				hay_colision = true
				break
		if !hay_colision:
			return result[0].collider.get_parent()
	return null

func robar_carta(carta_usada):
	cards.append(carta_usada.datos.ruta)
	var node_card = card_scene.instantiate()
	node_card.datos = load(cards.pop_front())
	deck.add_child(node_card)
	node_card.position = Vector2(carta_usada.position.x,140.0+300.0)
	await get_tree().create_timer(0.15).timeout
	carta_usada.queue_free()
	await get_tree().create_timer(2.7).timeout
	var tween = create_tween()
	tween.tween_property(node_card, "position:y", 140.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
