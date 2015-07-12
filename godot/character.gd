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
var upv = Vector3(0.0, 1.0, 0.0)
var sight
var anim
var attack = false
var skel
var coltrig = false
var animp
var damage_const = 16
var wrist_L_t
var wrist_R_t
var head_t

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
	anim.reset()
	anim.do_ko()
	if follow:
		follow = false
func switch_to_dead(st):
	dead = true
	anim.do_die()

var disable_grab = false
var state_to_anim = {
	STATE_NORMAL: {
		STATE_GRABKILL: "do_grabkill",
		STATE_GRABKILLED: "do_grabkilled",
	},
	STATE_GRABKILL: {
		STATE_NORMAL: "do_stop",
	},
	STATE_GRABKILLED: {
		STATE_NORMAL: "do_stop",
	},
	STATE_KO: {
		STATE_NORMAL: "do_stop",
		STATE_GRABKILL: "do_grabkill",
		STATE_GRABKILLED: "do_grabkilled",
	},
	STATE_ACTION: {
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
		if Input.is_action_pressed("pl_grab"):
			disable_grab = true
	elif st == STATE_GRABKILLED:
		set_mode(MODE_CHARACTER)

func switch_from_ko(st):
	ko = false

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
	sight = get_node("sight")
	skel = get_node(pl_objects[gfx_root]["skel"])
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
	hip_colb.add_child(col)
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
	sight.set_enabled(true)
	set_fixed_process(true)

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
#	add_child(c)
	c.set_translation(pos)
#	get_parent().remove_child(c)
	
func npc_follow(p):
	if !follow:
		apply_impulse(Vector3(0.0, 0.0, 0.0), p.get_global_transform().basis[2] * 2)
		follow = true
		_set_player(p)
func do_npc_follow(e):
	if ! e.follow:
		e.apply_impulse(Vector3(0.0, 0.0, 0.0), get_global_transform().basis[2] * 2)
		e.follow = true
		e._set_player(self)
func enemy_to_npc():
	enemy = false
	add_to_group("npc")
	remove_from_group("enemies")
	npc = true
	switch_state(STATE_NORMAL)
var attack_delay = 0.0
func do_chase(delta):
	var pt = game_player.get_transform()
	var ppos = pt.origin
	var npct = get_transform()
	set_transform(npct.looking_at(ppos, upv))
	if fear < strength:
		if get_linear_velocity().length() < 40 + strength / 10 and !sight.is_colliding():
			apply_impulse(Vector3(0.0, 0.0, 0.0), (ppos - npct.origin).normalized() * 500 * delta + upv * 250 * delta)
	elif (ppos - npct.origin).length() < 5:
		if get_linear_velocity().length() < 8 + strength / 10 and !sight.is_colliding():
			apply_impulse(Vector3(0.0, 0.0, 0.0), -(ppos - npct.origin).normalized() * 100 * delta + upv * 250 * delta)


func npc_state_normal(delta):
	if game_player != null and can_move():
		if follow:
			do_chase(delta)
			if sight.is_colliding():
				var c = sight.get_collider()
				if c.is_in_group("characters"):
					if !c.can_move():
						c.apply_impulse(Vector3(0.0, 0.0, 0.0), -get_transform().basis[2] * c.get_mass() * 2 + Vector3(0.0, 1.5, 0.0))
					elif c.is_in_group("enemies"):
						c.do_attack(c, 60)
func npc_state_ko(delta):
	if follow:
		ko = false
func npc_state_grabkill(delta):
	anim.do_grabkill()
func npc_state_grabkilled(delta):
	anim.do_grabkilled()
func enemy_state_normal(delta):
	if game_player != null and can_move():
		do_chase(delta)
		if !attack_delay > 0.0:
			if sight.is_colliding():
				var c = sight.get_collider()
				if c.is_in_group("enemies"):
					if randi() % 10 > 1:
						do_attack(c, 300)
						coltrig = true
				elif c.is_in_group("characters"):
					do_attack(c, 600)
				attack_delay = 1.0
		else:
			attack_delay -= delta
func enemy_state_ko(delta):
	pass
func enemy_state_grabkill(delta):
	pass
func enemy_state_grabkilled(delta):
	anim.do_grabkilled()
#var grab_delay = 0.0
var ord_enabled = false
func player_state_normal(delta):
	if can_move():
		if game_player == null:
			game_player = self
			get_tree().call_group(0, "enemies", "_set_player", self)
		var r = get_transform()
		if down.is_colliding() or get_linear_velocity().y <= 0.001:
			if Input.is_action_pressed("pl_left"):
				set_transform(r.rotated(Vector3(0.0, 1.0, 0.0), -0.1))
			if Input.is_action_pressed("pl_right"):
				set_transform(r.rotated(Vector3(0.0, 1.0, 0.0), 0.1))
			if Input.is_action_pressed("pl_forward"):
				if get_linear_velocity().length() < 10:
					apply_impulse(Vector3(0.0, 0.0, 0.0), -get_transform().basis[2]* get_mass() + Vector3(0.0, 2.5, 0.0))
			else:
				set_linear_velocity(get_linear_velocity() / 1.2)
			if Input.is_action_pressed("pl_jump"):
				apply_impulse(Vector3(0.0, 0.0, 0.0), Vector3(0.0, 200.0, 0.0))
			if Input.is_action_pressed("pl_attack"):
				attack = true
				if sight.is_colliding():
					var f = sight.get_collider()
					if f.is_in_group("characters"):
						do_attack(f, 20)
				else:
						do_attack(null, 0)
			if Input.is_action_pressed("pl_grab"):
				if not disable_grab:
					sight.process_orders(self)
#				if not disable_grab:
#					if sight.is_colliding() and grab_delay <= 0.0:
#						var f = sight.get_collider()
#						if f.is_in_group("npc"):
#							do_grab(f)
#						if f.is_in_group("enemies"):
#							do_grab(f)
#					disable_grab = true
			else:
					disable_grab = false

func player_state_dead(delta):
	if Input.is_action_pressed("pl_attack"):
		resurrect()

func player_state_ko(delta):
	if immortal:
		switch_state(STATE_NORMAL)

var old_pos
func player_state_grabkill(delta):
	anim.do_grabkill()
	if Input.is_action_pressed("pl_grab"):
		if not disable_grab:
			switch_state(STATE_NORMAL)
			grabbed_ch.switch_state(STATE_NORMAL)
			disable_grab = true
	else:
		disable_grab = false
	var trz = grabbed_ch.get_transform()
	var p = get_transform().origin
	var h = get_transform().basis[2]
	grabbed_ch.set_linear_velocity(Vector3(0.0, 0.0, 0.0))
	set_linear_velocity(Vector3(0.0, 0.0, 0.0))
	grabbed_ch.look_at_from_pos(p, p + h * 10, Vector3(0.0, 1.0, 0.0))
	var offt = hand_target.get_global_transform().origin - grabbed_ch.neck_target.get_global_transform().origin
	var ppos = get_global_transform()
	# offsetting the animation off hand a bit
	offt += ppos.basis[0] * (-0.05)
	offt += ppos.basis[2] * (-0.07)
	grabbed_ch.look_at_from_pos(p + offt, Vector3(p.x, p.y + offt.y, p.z), Vector3(0.0, 1.0, 0.0))
	look_at(p - h * 10, Vector3(0.0, 1.0, 0.0))
	var r = get_transform()
	if Input.is_action_pressed("pl_left"):
		set_transform(r.rotated(Vector3(0.0, 1.0, 0.0), -0.1))
	if Input.is_action_pressed("pl_right"):
		set_transform(r.rotated(Vector3(0.0, 1.0, 0.0), 0.1))
	if Input.is_action_pressed("pl_forward"):
		if get_linear_velocity().length() < 10:
			apply_impulse(Vector3(0.0, 0.0, 0.0), -get_transform().basis[2]* get_mass() * 10 + Vector3(0.0, 2.5, 0.0) * 3)


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
			
