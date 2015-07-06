
extends Area

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	set_enable_monitoring(true)
	connect("body_enter", self, "_enter")
	connect("body_exit", self, "_exit")

func _enter(body):
	print("enter:", body)
	if body.is_in_group("characters"):
		body.apply_impulse(Vector3(0.0, 0.0, 0.0), Vector3(0.0, 1.0, 0.0) * body.get_mass() * 10)

func _exit(body):
	print("exit:", body)
