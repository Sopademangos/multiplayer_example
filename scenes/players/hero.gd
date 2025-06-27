extends CharacterBody2D

@onready var death_scene: Control = $"../../../CanvasLayer/DeathScene"
@onready var animation_death_scene: AnimationPlayer = $"../../../CanvasLayer/DeathScene/AnimationPlayer"

@onready var skin: Sprite2D = $Skin
@onready var body: CollisionShape2D = $Body
@onready var area_daño: Area2D = $Area_daño
@onready var life: ProgressBar = $Life
@onready var arma: Area2D = $Arma
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var health: int = 100

@export var speed: int = 350
@export var acceleration: int = 10

@export var dash_speed: int = 2000
var dash_time = 0.2
var dash_cooldown: bool = false
var is_dashing: bool = false
var dash_direction = Vector2()

var knock_back = false
var knock_back_force = 15000

var enemy_direction = Vector2()

var bear_trap = false

func _ready() -> void:
	life.value = health + GlobalVar.hero_health_up
	speed += GlobalVar.hero_speed_up
	area_daño.connect("body_entered", _on_area_daño_body_entered)
	if Game.players[1].role == 1:
		set_multiplayer_authority(Game.players[1].id)
	else:
		set_multiplayer_authority(Game.players[0].id)

func _physics_process(delta: float) -> void:
	if knock_back:
		var knockback_direction = (global_position - enemy_direction).normalized()
		velocity = knockback_direction * knock_back_force * delta
		move_and_slide()
		await get_tree().create_timer(0.5).timeout
		knock_back = false
	else:
		if is_multiplayer_authority():
			var direction = Input.get_vector("left", "right", "up", "down").normalized() 
			_move_player(direction, delta)
			_send_data.rpc(direction, position, skin.flip_h, life.value)
	detecting_traps_areas()

func _move_player(direction, delta):
	if direction.x > 0:
		skin.flip_h = false
	elif direction.x < 0:
		skin.flip_h = true
	
	if direction != Vector2.ZERO:
		animation_player.play("run")
	else:
		animation_player.play("idle")
	var weight = delta * (acceleration if direction else 10)
	if !bear_trap:
		velocity = lerp(velocity, direction * speed, weight)
	else:
		velocity = Vector2.ZERO
	
	# Detectar la acción de Dash
	if Input.is_action_just_pressed("dash") and !dash_cooldown:
		area_daño.monitoring = false
		arma.monitorable = false
		arma.monitoring = false
		collision_layer &= ~2
		collision_mask &= ~2
		start_dash(direction, delta)
		is_dashing = true
	move_and_slide()

func start_dash(direction, delta):
	dash_cooldown = true
	dash_direction = direction.normalized()
	velocity = dash_direction*dash_speed
	velocity *= 1.0 - (8 * delta)
	await get_tree().create_timer(0.3).timeout
	is_dashing = false
	await get_tree().create_timer(0.7).timeout
	dash_cooldown = false
	area_daño.monitoring = true
	collision_layer |= 2
	collision_mask |= 2

@rpc("unreliable_ordered")
func _send_data(dir, pos: Vector2, flip_h: bool, hp: float) -> void:
	if dir != Vector2.ZERO:
		animation_player.play("run")
	else:
		animation_player.play("idle")
	position = lerp(position, pos, 0.5)
	skin.flip_h = flip_h
	life.value = hp

@rpc("unreliable_ordered")
func _trigger_death() -> void:
	animation_player.play("die")
	FloorManager.hero_defeated()
	queue_free()

func _health(_damage):
	life.value -= _damage
	if life.value <= 0:
		_trigger_death()
		_trigger_death.rpc()
		queue_free()

func _on_area_daño_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("enemy"):
		_health(_body.damage)
		if _body.type == 1:
			knock_back = true
			enemy_direction = _body.global_position

func detecting_traps_areas():
	if area_daño.monitoring:
		for area in area_daño.get_overlapping_areas():
			if area.is_in_group("enemy") and area.type == 0:
				_health(area.damage)
				if area._name == "Bear Trap":
					#print("valor de use de la beartrap: ", area.use)
					bear_trap = true
					area.bear_trap = true
					await get_tree().create_timer(3).timeout
					bear_trap = false
				else:
					knock_back = true
					enemy_direction = area.global_position
					area.use = 0
