
extends AnimationTreePlayer

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	set_active(true)

func can_oneshot():
	if !oneshot_node_is_active("blink") and  !oneshot_node_is_active("kneel"):
		return true
	else:
		return false
func do_blink():
	if can_oneshot():
		oneshot_node_start("blink")
func do_kneel():
	if can_oneshot():
		oneshot_node_start("kneel")
var walking = false
func do_walk():
	if walking:
		transition_node_set_current("idle_walk", 0)
		walking = false
	else:
		transition_node_set_current("idle_walk", 1)
		walking = true


