extends Node2D

const ARROW = preload("res://scenes/enemies/arrow.tscn")

@onready var pos_1: Marker2D = $pos1

var cooldown: bool = false

func _process(_delta: float) -> void:
	if !cooldown:
		pos_1.add_child(ARROW.instantiate())
		cooldown = true
		await get_tree().create_timer(3).timeout
		cooldown = false
