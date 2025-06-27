extends Node2D

const ARROW = preload("res://scenes/enemies/arrow/arrow.tscn")

var cooldown: bool = false

func _process(_delta: float) -> void:
	if !cooldown:
		for pos in self.get_children():
			pos.add_child(ARROW.instantiate())
		cooldown = true
		await get_tree().create_timer(3).timeout
		cooldown = false
