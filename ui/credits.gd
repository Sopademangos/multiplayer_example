class_name Credits
extends Control

@onready var back_button: Button = %BackButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var margin_container_2: MarginContainer = $MarginContainer2

func _ready() -> void:
	if GlobalVar.creditos:
		animation_player.play("fade_in")
		await get_tree().create_timer(0.2).timeout
		margin_container_2.visible = true
		GlobalVar.creditos = false
		back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/boot/boot.tscn"))
	else:
		margin_container_2.visible = true
		back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/main_menu.tscn"))
