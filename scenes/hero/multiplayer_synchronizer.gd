@tool
extends MultiplayerSynchronizer

# Define which properties to synchronize
@export var synchronized_properties = {
	"position": Vector2(),
	"velocity": Vector2(),
	"rotation": 0.0,
	"is_dashing": false,
	"knock_back": false,
	"health": 100
}



func _ready():
	# Set up the synchronizer to match the authority of the parent
	if not Engine.is_editor_hint() and get_parent():
		set_multiplayer_authority(get_parent().get_multiplayer_authority())
