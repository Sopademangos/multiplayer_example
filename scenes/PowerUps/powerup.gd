extends Node2D

@export var datos: PowerUp
@onready var enemy_powerup: Node2D = $"../../enemy_powerup/enemy_powerup"
@onready var parent_node: Control = $"../.."
@onready var buttons: Node2D = $"."

@onready var label: RichTextLabel = $Label
@onready var texture_button: TextureButton = $TextureButton

func _ready() -> void:
	if datos:
		label.text = datos.info
	texture_button.connect("pressed", _on_texture_button_pressed)

func _on_texture_button_pressed() -> void:
	if datos.player == "Hero":
		match datos.habilidad:
			"Damage":
				GlobalVar.hero_damage_up += datos.damage
			"Speed":
				GlobalVar.hero_speed_up += datos.speed
			"Health":
				GlobalVar.hero_health_up += datos.health
			"Damage Nerf":
				GlobalVar.enemy_damage_down += datos.damage
			"Speed Nerf":
				GlobalVar.enemy_speed_down += datos.speed
	else:
		match datos.habilidad:
			"Damage":
				GlobalVar.enemy_damage_up += datos.damage
			"Speed":
				GlobalVar.enemy_speed_up += datos.speed
			"Timer Speed":
				GlobalVar.fill_time_down += datos.timer_speed
			"Health":
				GlobalVar.enemy_health_up += datos.health
	_text_label.rpc("The other player choose: " + datos.info)
	await get_tree().create_timer(2).timeout
	_text_label.rpc("Wait for the other player to choose a reward")
	parent_node.visible = false
	FloorManager._continue()

@rpc("any_peer", "call_local", "reliable")
func _text_label(text):
	enemy_powerup.get_child(0).text = text
