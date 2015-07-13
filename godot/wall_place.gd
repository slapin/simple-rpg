
extends Area

# member variables here, example:
# var a=2
# var b="textvar"
var bodies_in = []
func _ready():
	# Initialization here
	connect("body_enter", self, "_enter")
	connect("body_exit", self, "_exit")
	set_process(true)
# bugs with constants
const STATE_ACTION = 4
const STATE_NORMAL = 0
func _enter(body):
	if body.is_in_group("npc"):
		bodies_in.append(body)
		body.switch_state("action")
		body.look_at_from_pos(get_transform().origin, get_global_transform().basis[2] * 10, Vector3(0.0, 0.0, 0.0))
func _exit(body):
	if body.is_in_group("npc"):
		bodies_in.append(body)
		body.switch_state("normal")

func _process(delta):
	for r in bodies_in:
		r.anim.do_wall_kneel()
