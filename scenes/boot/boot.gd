extends Control

@onready var anim = $AnimationPlayer

func _ready():
	await get_tree().create_timer(6).timeout
	anim.play("fade_out")
	await anim.animation_finished
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
