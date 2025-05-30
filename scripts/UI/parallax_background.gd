extends ParallaxBackground
@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

var scroll_speed := Vector2(50, 0)
var loop_length := 6000

func _ready() -> void:
	await get_tree().create_timer(7).timeout
	audio_stream_player.play()
	


func _process(delta):
	scroll_offset.x += scroll_speed.x * delta
	
	if scroll_offset.x >= loop_length:
		scroll_offset.x -= loop_length
