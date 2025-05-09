extends Node

var enemies = []  # Enemigos
var level_complete = false  # To track if the level is complete

# Call this function when an enemy is added to the level
func add_enemy(enemy):
	enemies.append(enemy)

# Check if all enemies are dead
func check_all_enemies_dead():
	for enemy in enemies:
		if enemy.is_alive():  # Assuming 'is_alive' is a method for enemy health
			return false
	return true

# Chequear si los enemigos estan vivos
func on_enemy_defeated():
	if check_all_enemies_dead() and not level_complete:
		complete_level()

# Nivel completado
func complete_level():
	level_complete = true
	get_tree().change_scene("res://level.tscn")
