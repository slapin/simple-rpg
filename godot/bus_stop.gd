
extends Area

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	connect("body_enter", self, "_enter")
	connect("body_exit", self, "_exit")

func _enter(body):
	if body.get_name() == "bus":
		body.set_brake(body.get_mass() * 20)
		print("BRAKE")
