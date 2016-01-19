extends Spatial

var height_scale = 1.0
# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	var sc = get_scale()
	sc.y = height_scale
	set_scale(sc)


