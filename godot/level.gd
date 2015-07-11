
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

export var camera_dist_min = 0.5
export var camera_dist_max = 6.0
export var camera_min_levitation = 4.0
export var autoturn_ray_aperture=25
export var autoturn_speed=50
var sun
var camera
var player
var physics_state
var cam_orig
var collision_exception=[]
var previous_pos = null
var interrior = false
var fl
var fb
var dbg
func _ready():
	camera = get_node("camera")
	player = get_node("player")
	fl = get_node("floor")
	physics_state = get_world().get_direct_space_state()
	cam_orig = camera.get_global_transform().origin
	collision_exception.append(player.get_rid())
	fb = get_node("fwd_button")
	dbg = get_node("debug")
	dbg.append_bbcode("hello")
	camera.set_as_toplevel(true)
	set_fixed_process(true)
func camera_set(dt):
	var target = player.get_global_transform().origin
	var pos = camera.get_global_transform().origin
	var up = Vector3(0.0, 1.0, 0.0)
	var delta = pos - target
	var min_lev
	var min_dist
	var max_dist
	if interrior:
		min_lev = camera_min_levitation / 2.0
		min_dist = camera_dist_min
		max_dist = camera_dist_max / 2.0
	else:
		min_lev = camera_min_levitation
		min_dist = camera_dist_min
		max_dist = camera_dist_max
	if delta.y < min_lev:
		delta.y = min_lev
	if delta.length() < min_dist:
		delta = delta.normalized() * min_dist
	if delta.length() > max_dist:
		delta = delta.normalized() * max_dist
	physics_state = get_world().get_direct_space_state()
	var col_left = physics_state.intersect_ray(target, target + Matrix3(up, deg2rad(autoturn_ray_aperture)).xform(delta), collision_exception)
	var col = physics_state.intersect_ray(target, target + delta, collision_exception)
	var col_right = physics_state.intersect_ray(target, target + Matrix3(up, deg2rad(-autoturn_ray_aperture)).xform(delta), collision_exception)
	if !col.empty():
		delta = col.position - target
	elif !col_left.empty() and col_right.empty():
		delta = Matrix3(up, deg2rad(-dt * autoturn_speed)).xform(delta)
	elif col_left.empty() and !col_right.empty():
		delta = Matrix3(up, deg2rad(dt * autoturn_speed)).xform(delta)
	
	if delta == Vector3():
		delta = (pos - target).normalized() * 0.0001
	pos = target + delta
	camera.look_at_from_pos(pos, target, up)
	if interrior:
		camera.set_perspective(80.0, camera.get_znear(), camera.get_zfar())
	else:
		camera.set_perspective(60.0, camera.get_znear(), camera.get_zfar())

func _fixed_process(delta):
	camera_set(delta)
	if fb.is_pressed():
		Input.action_press("pl_forward")
	
