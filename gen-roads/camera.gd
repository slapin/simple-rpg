
extends Camera

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	set_fixed_process(true)

func _fixed_process(dt):
	set_rotation(get_rotation() + Vector3(0.0, dt / 2, 0.0))



