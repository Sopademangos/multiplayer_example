extends Area2D

@export var _name: String
@export var damage: int = 0
@export var type: int = 1
@export var bear_trap: bool = false
@export var temporizador: bool = false
@onready var collision_body: CollisionShape2D = $Collision_body
var use = 1
@onready var skin: Sprite2D = $"../Skin"
@onready var smoke: Sprite2D = $"../Smoke"
@onready var bear_trap_skin: Sprite2D = $"../BearTrap"
@onready var fire_trap: Sprite2D = $"../FireTrap"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _process(_delta: float) -> void:
	if use <= 0 and !temporizador:
		_send_data.rpc()
		get_parent().queue_free()
	if temporizador:
		if _name == "Bomb":
			await get_tree().create_timer(3.0).timeout
			smoke.visible = true
			animation_player.play("bomb")
			await get_tree().create_timer(0.1).timeout
			skin.visible = false
			await get_tree().create_timer(0.1).timeout
			collision_body.disabled = false
			await get_tree().create_timer(1.3).timeout
			_send_data.rpc()
			get_parent().queue_free()
	if bear_trap:
		collision_body.disabled = true
	if _name == "Bear Trap":
		bear_trap_skin.visible = true
	elif _name == "Fire Trap":
		fire_trap.visible = true
		animation_player.play("fire_trap")

@rpc("any_peer", "call_local", "reliable")
func _send_data() -> void:
	get_parent().queue_free()
