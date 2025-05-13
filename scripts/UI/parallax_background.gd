extends ParallaxBackground

var scroll_speed := Vector2(50, 0)
var loop_length := 6000

func _process(delta):
	scroll_offset.x += scroll_speed.x * delta
	
	if scroll_offset.x >= loop_length:
		scroll_offset.x -= loop_length
