extends "res://simple_char.gd"

var hand_target
var neck_target

var gfx_root
var female

var grabbed_ch
var action

var body
var down
var nv = Vector3(0.0, 0.0, 0.0)
var anim
var attack = false
var skel
var coltrig = false
var animp
var damage_const = 16
var wrist_L_t
var wrist_R_t
var head_t
var bodycol
var bodycol_t

var pl_objects = {
	"man": {
				"anim": "man/AnimationPlayer",
				"skel": "man/711man/Skeleton",
				"bottom_clothes": "man/711man/Skeleton/pants",
	},
	"woman": {
				"anim": "woman/AnimationPlayer",
				"skel": "woman/711woman/Skeleton",
				"bottom_clothes": "woman/711woman/Skeleton/skirt",
	}
}

func switch_to_ko(st):
	ko = true
	if follow:
		follow = false
func switch_to_tripped(st):
	tripped = true
	if follow:
		follow = false
func switch_to_dead(st):
	dead = true
	anim.do_die()

var disable_grab = false
var state_to_anim = {
	STATE_NORMAL: {
		STATE_KO: "do_ko",
		STATE_GRABKILL: "do_grabkill",
		STATE_GRABKILLED: "do_grabkilled",
		STATE_TRIPPED: "do_ko",
	},
	STATE_GRABKILL: {
		STATE_KO: "do_ko",
		STATE_NORMAL: "do_stop",
	},
	STATE_GRABKILLED: {
		STATE_KO: "do_ko",
		STATE_NORMAL: "do_stop",
	},
	STATE_KO: {
		STATE_NORMAL: "do_stop",
		STATE_GRABKILL: "do_grabkill",
		STATE_GRABKILLED: "do_grabkilled",
	},
	STATE_ACTION: {
		STATE_KO: "do_ko",
		STATE_NORMAL: "do_stop",
		STATE_GRABKILL: "do_grabkill",
		STATE_GRABKILLED: "do_grabkilled",
	}
}

var state_pairs = {
	STATE_GRABKILL: STATE_GRABKILLED,
}

func switch_to_normal(st):
	if st == STATE_GRABKILL:
		grabbed_ch.remove_collision_exception_with(self)
		remove_collision_exception_with(grabbed_ch)
	elif st == STATE_GRABKILLED:
		set_mode(MODE_CHARACTER)
	if bodycol != null:
		add_shape(bodycol, bodycol_t)

func switch_from_normal(st):
	var hh
	for hh in range(0, get_shape_count()):
		var hn = get_shape(hh)
		if hn.get_name() == "bodycol":
			remove_shape(hh)

func switch_from_ko(st):
	ko = false

func switch_from_tripped(st):
	tripped = false

func switch_to_action(st):
	anim.do_stop()
	set_mode(MODE_KINEMATIC)

func switch_from_action(st):
	anim.do_stop()
	set_mode(MODE_CHARACTER)

func switch_to_grabkilled(st):
	set_mode(MODE_KINEMATIC)

func switch_from_grabkilled(st):
	set_mode(MODE_CHARACTER)

func switch_state(newstate):
	if typeof(newstate) == TYPE_STRING:
		newstate = text_to_state[newstate]
	if newstate != state:
		if state_to_anim.has(state):
			if state_to_anim[state].has(newstate):
				if anim.has_method(state_to_anim[state][newstate]):
					anim.call(state_to_anim[state][newstate])
				else:
					anim.call(state_to_anim[state][newstate])
	.switch_state(newstate)

var bone_spatials = {}
func add_bone_spatial(bone):
	var bone_t = skel.find_bone(bone)
	var bone_tr = skel.get_bone_global_pose(bone_t).origin
	var sp = Spatial.new()
	var sp1 = Spatial.new()
	sp.add_child(sp1)
	sp1.set_translation(bone_tr)
	skel.add_child(sp)
	skel.bind_child_node_to_bone(bone_t, sp)
	bone_spatials[bone] = sp1
var old_pos
func _ready():
#	._ready()
	if has_node("man"):
		gfx_root = "man"
		female = false
	else:
		gfx_root = "woman"
		female = true
	down = get_node("down")
	down.set_enabled(true)
	if enemy:
		add_to_group("enemies")
	if not enemy and not player:
		npc = true
		add_to_group("npc")
	add_to_group("characters")
	anim = get_node("anim")
	animp = get_node(pl_objects[gfx_root]["anim"])
	skel = get_node(pl_objects[gfx_root]["skel"])
	animp.set_animation_process_mode(animp.ANIMATION_PROCESS_FIXED)
#	var meshi = get_node(pl_objects[gfx_root]["bottom_clothes"])
#	var mesh = meshi.get_mesh().duplicate()
	wrist_L_t = skel.find_bone("wrist_L")
	wrist_R_t = skel.find_bone("wrist_R")
	head_t = skel.find_bone("head")
	add_bone_spatial("head")
	add_bone_spatial("neck02")
	add_bone_spatial("wrist_R")
	add_bone_spatial("wrist_L")
	add_bone_spatial("spine05")
	neck_target = bone_spatials["neck02"]
	hand_target = bone_spatials["wrist_R"]
	var hip_colb = bone_spatials["spine05"]
	var col = SphereShape.new()
	col.set_radius(0.3)
	add_shape(col)
#	var head_tr = skel.get_bone_global_pose(head_t).origin
#	tc.set_translation(head_tr)
	
#	var mat = mesh.surface_get_material(0).duplicate()
#	var c = Color(randf() / 2.0, randf() / 2.0, randf() / 2.0)
#	mat.set_parameter(mat.PARAM_DIFFUSE, c)
#	mesh.surface_set_material(0, mat)
#	meshi.set_mesh(mesh)
	anim.do_stop()
	old_pos = get_translation()
	
	var sc = get_shape_count()
	var hc
	for hc in range(0, sc):
		var sh = get_shape(hc)
		if sh.get_name() == "bodycol":
			bodycol = sh
			bodycol_t = get_shape_transform(hc)
	connect("body_enter", self, "_enter_col")
	connect("body_exit", self, "_exit_col")
	sight.set_enabled(true)
	set_fixed_process(true)

var colliders = []

func _enter_col(body):
	if body.is_in_group("characters"):
		colliders.append(body)
		print("see ", body.get_name())
func _exit_col(body):
	if body.is_in_group("characters"):
		colliders.erase(body)
		print("leave ", body.get_name())
		if orders_enabled:
			get_tree().call_group(0, "gui", "hide_orders", body)
			orders_enabled = false
#		print("NO ORDERS")


func do_attack(e, v):
	if e != null:
		e.apply_impulse(Vector3(0.0, 0.0, 0.0), -get_global_transform().basis[2] * v)
		punch(e)
	anim.do_punch()
	attack=true
func do_pair_state(c, st):
	switch_state(st)
	c.switch_state(state_pairs[st])
func do_grabkill(c):
	grabbed_ch = c
	do_pair_state(c, STATE_GRABKILL)
	add_collision_exception_with(c)
	c.add_collision_exception_with(self)
	var pos = c.get_translation() - get_translation()
	c.set_translation(pos)
	
func enemy_to_npc():
	enemy = false
	add_to_group("npc")
	remove_from_group("enemies")
	npc = true
	switch_state(STATE_NORMAL)
var attack_delay = 0.0

func enemy_attack_body(body):
	if body.is_in_group("enemies"):
		if randi() % 10 > 1:
			do_attack(body, 300)
			coltrig = true
	elif body.is_in_group("characters"):
		do_attack(body, 600)
func enemy_state_normal(delta):
	if game_player != null and can_move() and fear < strength:
		do_chase(delta)
		if !attack_delay > 0.0:
			var c
			if sight.is_colliding():
				c = sight.get_collider()
				enemy_attack_body(c)
				attack_delay = 1.0
			if colliders.size() > 0:
				for c in colliders:
					enemy_attack_body(c)
				attack_delay = 1.0
		else:
			attack_delay -= delta
	elif game_player != null and can_move():
		do_avoid(delta)
func enemy_state_ko(delta):
	pass
func enemy_state_grabkill(delta):
	pass
func enemy_state_grabkilled(delta):
	anim.do_grabkilled()
#var grab_delay = 0.0
var ord_enabled = false
var stop_delay = 0.0
func common_state_normal(delta):
	.common_state_normal(delta)
	if attack:
		attack = false
	var rv = get_linear_velocity()
	if rv.length() > 10:
		set_linear_velocity(rv.normalized() * 6)
	if can_move():
		var newpos = get_translation()
		var tv = newpos - old_pos
		tv.y = 0
		if tv.length() > 0.0:
			anim.do_walk(tv.length() * 2.0)
			stop_delay = 0.0
		else:
			stop_delay += delta
		old_pos = newpos
		if stop_delay > 0.1:
			anim.do_stop()
			stop_delay = 0.0

func _fixed_process(delta):
	var lv = get_linear_velocity()
#	if sight.is_colliding():
#		print(get_name(), " sight:", sight.is_colliding())
#		print(sight.get_collider())
#	run_state(delta)
#	if is_sleeping():
#		set_sleeping(false)
func set_follow(f):
	if is_in_group("npc"):
		print("Follow: ", get_name())
		if state == STATE_NORMAL:
			follow = f
			print("following normal")
		elif state == STATE_KO and f:
			switch_state(STATE_NORMAL)
			follow = f
			print("following ko")

var orders_enabled = false
func sight_process_orders(pl):
	var ifcol = sight.is_colliding() or colliders.size() > 0
	var collider = null
	if sight.is_colliding():
		collider = sight.get_collider()
		if !collider.is_in_group("characters"):
			collider = null
			ifcol = false
	elif colliders.size() > 0:
		collider = colliders[0]
	if !ifcol and orders_enabled == false:
		return
	elif !ifcol and orders_enabled == true:
		orders_enabled = false
	if collider == null:
		return

	var forceable = !collider.can_move() || collider.npc
	if ifcol and not orders_enabled:
		print("COL ", forceable, " ", collider.ko, collider.state)
		if forceable:
			get_tree().call_group(0, "gui", "show_orders", collider)
			orders_enabled = true
			print("ORDERS")
#need to disable per-char menus on lose of contact
#	elif !ifcol:
#		get_tree().call_group(0, "gui", "hide_orders", sight.get_collider())
#		orders_enabled = false
#		print("NO ORDERS")
