extends CanvasLayer

# References to scene nodes
@onready var card_container = $CardContainer
@onready var mana_label = $ManaDisplay/ManaLabel
@onready var mana_bar = $ManaDisplay/ManaBar
@onready var game_view = $GameView
@onready var targeting_cursor = $TargetingCursor

# Card scene preload
var card_scene = preload("res://scenes/Card.tscn")

# Reference to the villain controller
var villain_controller

# Current cards in hand
var cards_in_hand = []

# Targeting state
var is_targeting = false
var selected_card = null

# Card data - normally this would be loaded from a separate resource file
var card_database = [
	{
		"id": 1,
		"name": "Fireball",
		"description": "Deal 10 damage to the target",
		"mana_cost": 2,
		"card_type": "damage",
		"damage": 10,
		"requires_target": true,
		"texture_path": "res://icon.svg"  # Using default Godot icon for now
	},
	{
		"id": 2,
		"name": "Lightning Strike",
		"description": "Deal 20 damage to the target",
		"mana_cost": 4,
		"card_type": "damage",
		"damage": 20,
		"requires_target": true,
		"texture_path": "res://icon.svg"  # Using default Godot icon for now
	},
	{
		"id": 3,
		"name": "Skeleton",
		"description": "Spawn a skeleton at the target location",
		"mana_cost": 3,
		"card_type": "spawn",
		"enemy_type": "skeleton",
		"requires_target": true,
		"texture_path": "res://icon.svg"  # Using default Godot icon for now
	}
]

# Initialize the card UI
func initialize(controller_reference):
	villain_controller = controller_reference
	
	# Hide targeting cursor initially
	targeting_cursor.visible = false
	
	# Add initial cards to hand
	add_card_to_hand(0)  # Add Fireball
	add_card_to_hand(1)  # Add Lightning Strike
	add_card_to_hand(2)  # Add Skeleton

# Update the mana display
func update_mana_display(current, maximum):
	mana_label.text = str(int(current)) + "/" + str(maximum)
	mana_bar.value = (current / maximum) * 100

# Add a card to the hand
func add_card_to_hand(card_index):
	var card_data = card_database[card_index]
	
	# Create a new card instance
	var new_card = card_scene.instantiate()
	card_container.add_child(new_card)
	
	# Initialize the card with data
	new_card.initialize(card_data, self)
	
	# Add to our tracking array
	cards_in_hand.append(new_card)

# Process input for targeting
func _input(event):
	if not is_targeting:
		return
		
	if event is InputEventMouseMotion:
		# Update targeting cursor position
		targeting_cursor.global_position = event.global_position
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Confirm target position
		var target_position = event.global_position
		
		# Convert UI position to game world position if needed
		# This depends on how your game view is set up
		var world_position = convert_to_world_position(target_position)
		
		# Play the card at the target position
		if selected_card:
			complete_card_play(selected_card, world_position)
		
		# End targeting mode
		end_targeting_mode()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Cancel targeting
		end_targeting_mode()
		print("Targeting cancelled")

# Called when a card is selected
func select_card(card_instance):
	var card_data = card_instance.card_data
	
	# Check if we have enough mana
	if villain_controller.current_mana < card_data.mana_cost:
		print("Not enough mana!")
		return
	
	# If the card requires targeting
	if card_data.requires_target:
		# Enter targeting mode
		is_targeting = true
		selected_card = card_instance
		
		# Show targeting cursor
		targeting_cursor.visible = true
		
		print("Select a target for " + card_data.name)
	else:
		# Play the card immediately without targeting
		complete_card_play(card_instance)

# Complete playing a card after any targeting is done
func complete_card_play(card_instance, target_position = null):
	var card_data = card_instance.card_data
	
	# Try to play the card
	if villain_controller.play_card(card_data, target_position):
		# Remove the card from hand
		card_instance.queue_free()
		cards_in_hand.erase(card_instance)
		
		# Add a new random card to hand
		var random_card_index = randi() % card_database.size()
		add_card_to_hand(random_card_index)

# End targeting mode
func end_targeting_mode():
	is_targeting = false
	selected_card = null
	targeting_cursor.visible = false

# Helper function to convert UI coordinates to world coordinates
func convert_to_world_position(ui_position):
	# This is a simple implementation and might need to be adjusted
	# depending on how your game view is set up
	
	# If the game view is a direct representation of the world:
	var game_view_rect = game_view.get_global_rect()
	var relative_position = ui_position - game_view_rect.position
	
	# Scale based on any viewport scaling
	# This would depend on how your game world is scaled in the view
	
	# For now, just return the relative position
	return relative_position
