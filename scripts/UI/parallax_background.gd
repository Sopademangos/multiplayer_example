extends ParallaxBackground
@onready var intro_audio: AudioStreamPlayer = $"../Intro"
@onready var loop_audio: AudioStreamPlayer = $"../loop"

var scroll_speed := Vector2(50, 0)
var loop_length := 6000
var is_active := true

func _ready() -> void:
	await get_tree().create_timer(7).timeout
	intro_audio.play()
	
func _process(delta):
	if !is_active:
		return
	scroll_offset.x += scroll_speed.x * delta
	
	if scroll_offset.x >= loop_length:
		scroll_offset.x -= loop_length


func _on_loop_finished() -> void:
	loop_audio.play()
