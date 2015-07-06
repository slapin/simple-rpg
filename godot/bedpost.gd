
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"
var area
var col
func _ready():
	# Initialization here
	area = get_node("bed/Area")
	area.connect("body_enter", self, "_bed_enter")
	area.connect("body_exit", self, "_bed_exitr")

func _bed_enter(body):
	if body.is_in_group("characters"):
		print("wtf")
		var m = body.get_mode()
		body.set_mode(body.MODE_KINEMATIC)
		body.set_linear_velocity(Vector3(0.0, 0.0, 0.0))
		var pos = body.get_translation()
		pos += Vector3(0.0, 0.5, 0.0)
		body.set_translation(pos)
		body.set_mode(m)

func _bed_exit(body):
	if body.is_in_group("characters"):
		body.set_mode(body.MODE_CHARACTER)
