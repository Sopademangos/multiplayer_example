extends Control

@onready var buttons: Node2D = $Buttons
@onready var enemy_powerup: Node2D = $enemy_powerup
const POWERUP = preload("res://scenes/PowerUps/powerup.tscn")
const DAMAGE = preload("res://scenes/PowerUps/types/villain/damage.tres")
const HEALTH = preload("res://scenes/PowerUps/types/villain/health.tres")
const SPEED = preload("res://scenes/PowerUps/types/villain/speed.tres")
const TIMER_SPEED = preload("res://scenes/PowerUps/types/villain/timer_speed.tres")
var cartas = [DAMAGE, HEALTH, SPEED, TIMER_SPEED]

func _ready() -> void:
	randomize()  # Inicializa el generador de números aleatorios
	#elegir_cartas_aleatorias()
	if Game.players[0].role == 1:
		_activated.rpc(true)
	else:
		_activated.rpc(false)

func elegir_cartas_aleatorias():
	if buttons.get_children():
		for boton in buttons.get_children():
			boton.queue_free()
	var copia_cartas = cartas.duplicate()  # Hacemos una copia para no modificar la original
	copia_cartas.shuffle()  # Mezclamos la lista
	var pos = 0
	while pos < 3:
		var boton = POWERUP.instantiate()
		boton.datos = copia_cartas[pos]
		buttons.add_child(boton)
		boton.position = Vector2(90 + (155 * pos), 132)
		pos += 1

#Activa el label de win del player que maneja al heroe
@rpc("any_peer", "call_local", "reliable")
func _activated(player1: bool):
	FloorManager.enemies_remaining = 0
	if player1:
		if multiplayer.get_unique_id() == 1:
			enemy_powerup.visible = true
		else:
			buttons.visible = true
	else:
		if multiplayer.get_unique_id() == 1:
			buttons.visible = true
		else:
			enemy_powerup.visible = true
