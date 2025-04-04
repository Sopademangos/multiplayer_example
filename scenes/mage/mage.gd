extends Node


# Villain controller properties
@export var max_mana := 10
@export var current_mana := 3
@export var mana_regen_rate := 1.0  # Mana points per second

# Card system references
@onready var card_ui = $CardUI

# References to the game world/hero
var game_world  # This would reference the main game scene
var hero  # This would reference the hero character

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize the card UI
	card_ui.initialize(self)
	
	# Get references to the game world and hero
	# This assumes the villain controller is a child of the main game scene
	game_world = get_parent()
	hero = game_world.get_node("Hero")  # Adjust the path as needed

# Called every frame
func _process(delta):
	# Handle mana regeneration
	regenerate_mana(delta)
	
	# Update UI elements
	card_ui.update_mana_display(current_mana, max_mana)

# Mana regeneration
func regenerate_mana(delta):
	if current_mana < max_mana:
		current_mana = min(current_mana + mana_regen_rate * delta, max_mana)

# Called when a card is played
func play_card(card_data, target_position = null):
	# Check if we have enough mana
	if current_mana >= card_data.mana_cost:
		# Deduct the mana cost
		current_mana -= card_data.mana_cost
		
		# Execute the card effect based on type
		match card_data.card_type:
			"damage":
				deal_damage(card_data.damage, target_position)
			"spawn":
				spawn_enemy(card_data.enemy_type, target_position)
			"trap":
				place_trap(card_data.trap_type, target_position)
			_:
				print("Unknown card type: ", card_data.card_type)
		
		return true
	else:
		print("Not enough mana!")
		return false

# Damage function (targets hero or position)
func deal_damage(damage_amount, target_position = null):
	if target_position:
		# Create a damage effect at the specified position
		# This could be an explosion, projectile, etc.
		create_damage_effect(target_position, damage_amount)
	else:
		# Direct damage to the hero
		if hero:
			print("Dealing ", damage_amount, " damage to hero")
			# This would call a method on the hero to reduce health
			# hero.take_damage(damage_amount)

# Create a damage effect in the world
func create_damage_effect(position, damage):
	print("Creating damage effect of ", damage, " at position ", position)
	# You would create a scene instance here that shows the damage effect
	# For example, an explosion, lightning strike, etc.
	
	# Example (commented out since we don't have the scenes yet):
	# var damage_effect = preload("res://scenes/DamageEffect.tscn").instantiate()
	# damage_effect.global_position = position
	# damage_effect.damage = damage
	# game_world.add_child(damage_effect)

# Spawn an enemy at the specified position
func spawn_enemy(enemy_type, position):
	print("Spawning enemy of type ", enemy_type, " at position ", position)
	# You would instantiate an enemy scene here

# Place a trap at the specified position
func place_trap(trap_type, position):
	print("Placing trap of type ", trap_type, " at position ", position)
	# You would instantiate a trap scene here
