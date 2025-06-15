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

@export var datos: Resource

@onready var players: Node2D = $"../../Players"
@onready var area: Area2D = $Area_collision
@onready var area_collision: CollisionShape2D = $Area_collision/Collision_body
@onready var timer: Timer = $Navigation_timer

var type = 1 #0 is a Trap, 1 is the enemy and 2 is a box
@export var health: int = 100
@export var damage: int = 10
@export var speed: int = 15000
var knock_back = false
var enemy_direction = Vector2()
var figura_coll: Shape2D
var is_dead = false
# Nos permite dañar al enemigo solo una vez por swing
var iframes = false
var use = 1

func _ready() -> void:
	area.connect("area_entered", _on_collision_area_entered)
	timer.connect("timeout", _on_timer_timeout)
	nav_agent.target_position = players.get_child(0).global_position
	life.value = health
	FloorManager.enemy_spawned()

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
	if type != 1:
		skin.hframes = 1

func setup(nombre: String, velocidad: int, hp: int, daño: int, icono: String, tipo: int, colision: int, radio: float, altura: float, tamaño: Vector2, pos_colision: Vector2, escala_imagen: Vector2):
	health = hp
	damage = daño
	speed = velocidad
	skin.texture = load(icono)
	life.max_value = health
	life.value = health
	type = tipo
	if tipo == 0 or tipo == 2: #Podríamos eliminar la barra, el navegation agent y el timer
		FloorManager.enemy_defeated()
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
	position = lerp(position, pos, 0.5)
	skin.flip_h = flip
	life.value = hp
	if life.value <= 0:
		queue_free()

func _health(_damage):
	# Ahora al enemigo solo lo podemos dañar una vez con cada swing
	if !iframes:
		life.value -= _damage
		if life.value <= 0:
			if type == 1:
				FloorManager.enemy_defeated()
			queue_free()
		iframes = true
		await get_tree().create_timer(0.2).timeout
		iframes = false

func _on_collision_area_entered(_area: Area2D) -> void:
	if _area.is_in_group("hero") and type != 0:
		_health(_area.damage)
		knock_back = true
		enemy_direction = _area.global_position

func _on_timer_timeout() -> void:
	nav_agent.target_position = players.get_child(0).global_position
	timer.start()
