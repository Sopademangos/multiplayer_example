extends Area2D

@onready var body: CollisionShape2D = $body
@onready var skin: Sprite2D = $skin

@export var damage: int = 20
@export var swing_cooldown: float = 0.2  # Cooldown del swing
@export var swing_angle: float = 120.0  # Angulo de la espada
@export var swing_duration: float = 0.2  # Duracion del swing

var can_attack: bool = true
var is_attacking: bool = false
var base_rotation: float = 0.0
var swing_timer: float = 0.0
var start_angle: float = 0.0
var end_angle: float = 0.0

func _ready():
	# Important: Disable monitoring at start so weapon doesn't deal damage continuously
	monitoring = false
	monitorable = false
	connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if is_attacking:
			# Animacion de la espada
			swing_timer += delta
			var progress = swing_timer / swing_duration
			
			if progress <= 1.0:
				# Interpolar entre la posicion inicial y final
				var current_angle = lerp_angle(start_angle, end_angle, progress)
				rotation = current_angle
				_update_weapon_rotation.rpc(rotation)
			
			# terminamos
			if progress >= 1.0:
				is_attacking = false
				monitoring = false
				monitorable = false
				swing_timer = 0.0
				
				# Cooldown para no espamear
				await get_tree().create_timer(swing_cooldown).timeout
				can_attack = true
		else:
			# Follow mouse when not attacking
			var target_angle = (get_global_mouse_position() - global_position).angle()
			base_rotation = lerp_angle(rotation, target_angle, 6.5 * delta)
			rotation = base_rotation
			_update_weapon_rotation.rpc(base_rotation)
		
		# Handle attack input
		if Input.is_action_just_pressed("attack") and can_attack and !is_attacking:
			swing()

func swing():
	can_attack = false
	is_attacking = true
	swing_timer = 0.0
	
	# Guardamos la rotacion del momento
	base_rotation = rotation
	
	#El arco de daño de la espada sería de unos 120 grados, 60 a la izq y 60 a la der
	var half_angle = swing_angle / 2.0 * PI / 180.0
	start_angle = base_rotation - half_angle  # Empezamos a la izquierda de la posicion inicial
	end_angle = base_rotation + half_angle    # Terminamos al final
	
	# Colisiones solo cuando estamos moviendo la espada
	monitoring = true
	monitorable = true

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("enemy"):
		_body._health(damage)

@rpc("call_local")
func _update_weapon_rotation(new_rotation: float):
	rotation = new_rotation
