extends Area2D

var damage: int = 15
var velocity: int = 200
var type = 0
var _name = "arrow"
var use = 1

# Mueve la flecha a la derecha
func _process(delta: float) -> void:
	position.x += velocity * delta
	if use <= 0:
		queue_free()
