extends CharacterBody2D

#Skins
const SLIME = preload("res://assets/enemies/slime.png")
const SMOKE_BOMB = preload("res://assets/enemies/smoke_bomb.png")
const SNAIL = preload("res://assets/enemies/snail.png")
const TANK = preload("res://assets/enemies/tank.png")
const THE_BEAST = preload("res://assets/enemies/the_beast.png")

@onready var skin: Sprite2D = $Skin
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var life: ProgressBar = $Life
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var collision: CollisionShape2D = $Body

@export var datos: CardData

@onready var players: Node2D = $"../../Players"
@onready var area: Area2D = $Area_collision
@onready var area_collision: CollisionShape2D = $Area_collision/Collision_body
@onready var timer: Timer = $Navigation_timer

var type = 1 #0 is a Trap, 1 is the enemy and 2 is a box
@export var boss: bool = false
@export var health: int = 100
@export var damage: int = 10
@export var speed: int = 15000
var knock_back = false
var enemy_direction = Vector2()
var figura_coll: Shape2D
# Nos permite dañar al enemigo solo una vez por swing
var iframes = false

func _ready() -> void:
	life.value = health
	if datos:
		setup(datos.nombre,datos.velocidad,datos.hp,datos.daño,datos.icono,datos.tipo,datos.colision,datos.radio,datos.altura,datos.tamaño,datos.posicion_colision,datos.escala_de_la_figura)
	area.connect("area_entered", _on_collision_area_entered)
	timer.connect("timeout", _on_timer_timeout)
	nav_agent.target_position = players.get_child(0).global_position

func _physics_process(delta: float) -> void:
	if type == 1 and !nav_agent.is_target_reached():
		animation_player.play("move")
		var target_pos = nav_agent.get_next_path_position()
		var dir = (target_pos - global_position).normalized()
		if dir.x > 0:
			skin.flip_h = false
		else:
			skin.flip_h = true
		
		if knock_back:
			var knockback_direction = (global_position - enemy_direction).normalized()
			if boss:
				velocity = knockback_direction * 10000 * delta
			else:
				velocity = knockback_direction * 25000 * delta
			move_and_slide()
			_send_data.rpc(position, skin.flip_h, life.value)
			await get_tree().create_timer(0.5).timeout
			knock_back = false
		else:
			if is_multiplayer_authority():
				velocity = dir * speed * delta
				move_and_slide()
				_send_data.rpc(position, skin.flip_h, life.value)
	elif type == 2: #En caso de destruir la caja, esta desaparezca de ambas pantallas
		_send_data.rpc(position, skin.flip_h, life.value)
	if type != 1  or boss:
		skin.hframes = 1

func setup(nombre: String, velocidad: int, hp: int, daño: int, icono: String, tipo: int, colision: int, radio: float, altura: float, tamaño: Vector2, pos_colision: Vector2, escala_imagen: Vector2):
	health = hp
	damage = daño
	speed = velocidad
	skin.texture = load(icono)
	life.max_value = health
	life.value = health
	type = tipo
	if tipo == 1: #Podríamos eliminar la barra, el navegation agent y el timer
		FloorManager.enemy_spawned()
	if (tipo == 0 or tipo == 2) and !boss:
		#FloorManager.enemy_defeated()
		life.visible = false
	if colision == 0:
		figura_coll = CircleShape2D.new()
		figura_coll.radius = radio
	elif colision == 1:
		figura_coll = CapsuleShape2D.new()
		figura_coll.radius = radio
		figura_coll.height = altura
	else:
		figura_coll = RectangleShape2D.new()
		figura_coll.size = tamaño
	collision.shape = figura_coll
	area_collision.shape = figura_coll
	collision.position = pos_colision
	area_collision.position = pos_colision
	if tipo == 0: # si es una trampa no tiene un collision shape pero si un area collision
		area.damage = daño
		area.type = tipo
		area._name = nombre
		collision.disabled = true
		if nombre == "Bomb":
			area_collision.disabled = true
			area.temporizador = true
		if nombre == "Bear Trap" or nombre == "Fire Trap":
			skin.visible = false
	if escala_imagen != Vector2(0.0, 0.0):
		scale = escala_imagen
	if nombre == "The Beast":
		skin.texture = THE_BEAST
	elif nombre == "Tank":
		skin.texture = TANK
	elif nombre == "Slime":
		skin.texture = SLIME
	elif nombre == "Snail":
		skin.texture = SNAIL

@rpc("any_peer", "call_local", "reliable")
func _send_data(pos: Vector2, flip: bool, hp: float) -> void:
	position = lerp(position, pos, 0.1)
	skin.flip_h = flip
	#life.value = hp

@rpc("any_peer", "call_local", "reliable")
func _kill_it():
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func _damage(hp: float) -> void:
	life.value = hp
	skin.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.4).timeout
	skin.modulate = Color(1, 1, 1)

func _health(_damage):
	#print("damage to enemy: ", _damage, " vida restante: ", life.value)
	# Ahora al enemigo solo lo podemos dañar una vez con cada swing
	if !iframes:
		life.value -= _damage
		skin.modulate = Color(1, 0.3, 0.3)
		if life.value <= 0:
			if type == 1:
				FloorManager.enemy_defeated()
			queue_free()
			_kill_it.rpc()
		iframes = true
		await get_tree().create_timer(0.4).timeout
		skin.modulate = Color(1, 1, 1)
		iframes = false

func _on_collision_area_entered(_area: Area2D) -> void:
	if _area.is_in_group("hero") and type != 0:
		_health(_area.damage)
		_damage.rpc(life.value)
		knock_back = true
		enemy_direction = _area.global_position

func _on_timer_timeout() -> void:
	nav_agent.target_position = players.get_child(0).global_position
	timer.start()
