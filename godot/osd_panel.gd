
extends Panel

# member variables here, example:
# var a=2
# var b="textvar"
var health_data
var fps_data
func _ready():
	# Initialization here
	health_data = get_node("health/health_data")
	fps_data = get_node("fps/fps_data")
	add_to_group("gui")
	set_process(true)

func set_health(health):
	health_data.set_text(str(health))

func _process(delta):
	fps_data.set_text(str(OS.get_frames_per_second()))