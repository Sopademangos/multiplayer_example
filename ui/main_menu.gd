class_name MainMenu
extends Control


@onready var host: Button = %Host
@onready var join: Button = %Join
@onready var how_to: Button = %HowTo
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit
@onready var back_button: Button = %BackButton
@onready var how_to_play_scene: Control = $How_to_play
@onready var margin_container: MarginContainer = $MarginContainer
@onready var margin_container_3: MarginContainer = $MarginContainer3
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	#if Game.multiplayer_test:
		#get_tree().change_scene_to_file("res://lobby/lobby_test.tscn")
		#return
	
	quit.pressed.connect(func(): get_tree().quit())
	host.pressed.connect(func(): 
		get_tree().change_scene_to_file("res://lobby/host_screen.tscn")
	)
	join.pressed.connect(func(): get_tree().change_scene_to_file("res://lobby/join_screen.tscn"))
	credits.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/credits.tscn"))
	
	#host.grab_focus()
	
	how_to.connect("pressed", _on_how_to_pressed)
	back_button.connect("pressed", _on_back_button_pressed)

func _on_how_to_pressed() -> void:
	how_to_play_scene.visible = true
	margin_container.visible = false
	margin_container_3.visible = false

func _on_back_button_pressed() -> void:
	how_to_play_scene.visible = false
	margin_container.visible = true
	margin_container_3.visible = true
