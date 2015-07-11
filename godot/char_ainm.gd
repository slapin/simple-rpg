
extends AnimationTreePlayer

# member variables here, example:
# var a=2
# var b="textvar"
var punch_delay = 0.0
export var punch_time = 0.5
export var walk_scale = 0.01


const ANIM_KO = 0
const ANIM_PUNCH = 1
const ANIM_WALK = 2
const ANIM_STOP = 3
const ANIM_DIE = 4
const ANIM_GRABKILL = 5
const ANIM_GRABKILLED = 6
const ANIM_WALL_KNEEL = 7

var current_anim = -1
var oldsc = 0.0
func switch_anim(anim, sc=1.0):
	if current_anim != anim:
		transition_node_set_current("stay_walk", 0)
		transition_node_set_current("active_state", 0)
		transition_node_set_current("active_passive", 0)
		if anim == ANIM_KO:
			transition_node_set_current("passive_state", 2)
			transition_node_set_current("active_passive", 1)
		elif anim == ANIM_PUNCH:
			transition_node_set_current("punch", 1.0)
			punch_delay = punch_time
			var anim = animation_node_get_animation("punch_anim")
			anim.set_loop(true)
			animation_node_set_animation("punch_anim", anim)
		elif anim == ANIM_WALK:
#			timescale_node_set_scale("walk_scale", sc / (walk_scale + walk_scale_add))
			timescale_node_set_scale("walk_scale", sc * 19.0)
			transition_node_set_current("stay_walk", 1)
			oldsc = sc
		elif anim == ANIM_STOP:
			transition_node_set_current("stay_walk", 0)
			transition_node_set_current("passive_state", 0)
			transition_node_set_current("active_state", 0)
			transition_node_set_current("active_passive", 0)
		elif anim == ANIM_DIE:
			transition_node_set_current("passive_state", 0)
			transition_node_set_current("active_passive", 1)
		elif anim == ANIM_GRABKILL:
			transition_node_set_current("passive_state", 0)
			transition_node_set_current("active_state", 3)
			transition_node_set_current("active_passive", 0)
		elif anim == ANIM_GRABKILLED:
			transition_node_set_current("passive_state", 1)
			transition_node_set_current("active_passive", 1)
		elif anim == ANIM_WALL_KNEEL:
			transition_node_set_current("passive_state", 3)
			transition_node_set_current("active_passive", 1)
		current_anim = anim
	else:
		if anim == ANIM_WALK and sc != oldsc:
			timescale_node_set_scale("walk_scale", sc * 19.0)
			oldsc = sc
	

var walk_scale_add
func _ready():
	switch_anim(ANIM_STOP)
	walk_scale_add = 0.0
	set_active(false)
	set_fixed_process(false)
func do_ko():
	switch_anim(ANIM_KO)
func do_punch():
	switch_anim(ANIM_PUNCH)

# special animation, do not set transitions
func do_walk(sc):
	switch_anim(ANIM_WALK, sc)
func do_stop():
	switch_anim(ANIM_STOP)
func do_die():
	switch_anim(ANIM_DIE)
func do_grabkill():
	switch_anim(ANIM_GRABKILL)
func do_grabkilled():
	switch_anim(ANIM_GRABKILLED)
func do_wall_kneel():
	switch_anim(ANIM_WALL_KNEEL)

func _fixed_process(delta):
	if (punch_delay > 0.0):
		punch_delay -= delta
	else:
		transition_node_set_current("punch", 0)
