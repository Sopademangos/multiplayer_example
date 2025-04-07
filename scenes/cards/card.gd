extends Control

# Card properties
var card_data = null
var card_ui = null

# References to nodes
@onready var card_name = $CardPanel/CardName
@onready var card_description = $CardPanel/CardDescription
@onready var card_cost = $CardPanel/ManaCost
@onready var card_image = $CardPanel/CardImage

# Initialize the card with data
func initialize(data, ui_reference):
	card_data = data
	card_ui = ui_reference
	
	# Set the card visuals
	card_name.text = data.name
	card_description.text = data.description
	card_cost.text = str(data.mana_cost)
	
	# Set the card image if it exists
	if ResourceLoader.exists(data.texture_path):
		var texture = load(data.texture_path)
		card_image.texture = texture

# Handle mouse input
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Select this card for playing
		card_ui.select_card(self)
		accept_event()

# Hover effects
func _on_mouse_entered():
	# Scale up slightly for a hover effect
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited():
	# Scale back to normal
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
