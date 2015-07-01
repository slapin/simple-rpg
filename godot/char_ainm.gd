
extends AnimationTreePlayer

# member variables here, example:
# var a=2
# var b="textvar"
var punch_delay = 0.0
export var punch_time = 0.5
export var walk_scale = 2.1
func _ready():
	set_active(true)
	set_fixed_process(true)
func do_ko():
	do_stop()
	transition_node_set_current("passive_state", 2)
	transition_node_set_current("active_passive", 1)
func do_punch():
	transition_node_set_current("punch", 1.0)
	punch_delay = punch_time
	var anim = animation_node_get_animation("punch_anim")
	anim.set_loop(true)
	animation_node_set_animation("punch_anim", anim)

# special animation, do not set transitions
func do_walk(sc):
	timescale_node_set_scale("walk_scale", sc / walk_scale)
	transition_node_set_current("stay_walk", 1)
func do_stop():
	transition_node_set_current("stay_walk", 0)
	transition_node_set_current("active_state", 0)
	transition_node_set_current("active_passive", 0)
func do_die():
	do_stop()
	transition_node_set_current("passive_state", 0)
	transition_node_set_current("active_passive", 1)


func _fixed_process(delta):
	if (punch_delay > 0.0):
		punch_delay -= delta
	else:
		transition_node_set_current("punch", 0)
