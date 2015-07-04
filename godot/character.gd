
extends RigidBody

export var enemy = false
export var player = false
export var mass = 70
export var strength = 10
export var health = 100
export var immortal = false

var hand_target
var neck_target

var max_health
var dead = false
var ko = false
var gfx_root
var npc = false
var follow = false

class HipsSphere extends BoneAttachment:
	var skel
	var col
	var mover
	var body
	var tbone = Vector3(0.0, 0.1, -1.0)
	func _init(b):
		._init()
		body = b
	func _ready():
		skel = get_parent()
		skel.add_child(self)
		self.bone_name = "spine05"
		col = SphereShape.new()
		col.set_radius(0.3)
		mover = Spatial.new()
		add_child(mover)
		mover.set_translation(tbone)
		mover.add_child(col)
		body.add_shape(col)

const STATE_NORMAL = 0
const STATE_GRABKILL = 1
const STATE_GRABKILLED = 2
var state = STATE_NORMAL
var grabbed_ch

var body
var down
var game_player = null
var nv = Vector3(0.0, 0.0, 0.0)
var upv = Vector3(0.0, 1.0, 0.0)
var sight
var anim
var attack = false
var hip_attach
var skel
var coltrig = false
var animp
var damage_const = 16
var level = 0
var score = 0
var next_score
func can_move():
	if not ko and not dead:
		return true
	else:
		return false
func punched(c, dam):
	var defence = strength / 10
	var damage = dam / (defence + 1)
	if ! immortal:
		health -= damage
	if health > 0 and damage > strength * 3:
		ko = true
		anim.reset()
		anim.do_ko()
		if follow:
			follow = false
	var dtest = 10 + randi() % strength
	if dtest < 0:
		dtest = 0
	if health < dtest:
		ko = true
		anim.reset()
		anim.do_ko()
		follow = false
	if health < 0:
		health = 0
		dead = true
		anim.reset()
		anim.do_die()
	if player:
		get_tree().call_group(0, "gui", "set_health", health)
func punch(c):
	c.punched(self, randi() % strength + strength / 10)
	score += 1

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
func switch_state(newstate):
	if newstate != state:
		if state == STATE_NORMAL:
			if newstate == STATE_GRABKILL:
				anim.do_grabkill()
			elif newstate == STATE_GRABKILLED:
				anim.do_grabkilled()
		elif state == STATE_GRABKILL:
			if newstate == STATE_GRABKILLED:
				pass
			elif newstate == STATE_NORMAL:
				anim.do_stop()
		elif state == STATE_GRABKILLED:
			if newstate == STATE_GRABKILL:
				pass
			elif newstate == STATE_NORMAL:
				anim.do_idle()
		state = newstate


func _ready():
	if has_node("neck-target"):
		neck_target = get_node("neck-target").get_transform()
	if has_node("hand-target"):
		hand_target = get_node("hand-target").get_transform()
	if has_node("man"):
		gfx_root = "man"
	else:
		gfx_root = "woman"
	max_health = health
	set_mode(self.MODE_CHARACTER)
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
	hip_attach = HipsSphere.new(self)
	skel.add_child(hip_attach)
	var meshi = get_node(pl_objects[gfx_root]["bottom_clothes"])
	var mesh = meshi.get_mesh().duplicate()
	
	var mat = mesh.surface_get_material(0).duplicate()
	var c = Color(randf() / 2.0, randf() / 2.0, randf() / 2.0)
	mat.set_parameter(mat.PARAM_DIFFUSE, c)
	mesh.surface_set_material(0, mat)
	meshi.set_mesh(mesh)
	anim.do_stop()
	next_score = 10
	
	sight.set_enabled(true)
	set_fixed_process(true)
func _set_player(pl):
	game_player = pl

func do_attack(e, v):
	if e != null:
		e.apply_impulse(Vector3(0.0, 0.0, 0.0), -get_global_transform().basis[2] * v)
		punch(e)
	anim.do_punch()
	attack=true
func do_grabkill(c):
	switch_state(STATE_GRABKILL)
	c.switch_state(STATE_GRABKILLED)
	c.set_mode(MODE_KINEMATIC)
	var trz = c.get_transform()
	var p = get_transform().origin
	var h = get_transform().basis[2]
	var th = Vector3(-c.neck_target.origin.x, c.neck_target.origin.y, c.neck_target.origin.z)
	var offt = hand_target.origin - th
	print(offt)
	add_collision_exception_with(c)
	c.add_collision_exception_with(self)
	c.set_linear_velocity(Vector3(0.0, 0.0, 0.0))
	set_linear_velocity(Vector3(0.0, 0.0, 0.0))
	look_at(p - h * 10 , Vector3(0.0, 1.0, 0.0))
	c.look_at_from_pos(p, p + h * 10 + offt, Vector3(0.0, 1.0, 0.0))
	var offt = get_node("hand-target").get_global_transform().origin - c.get_node("neck-target").get_global_transform().origin
	c.look_at_from_pos(p + offt, p + h * 10, Vector3(0.0, 1.0, 0.0))
	grabbed_ch = c
func do_grab(e):
	if e != null and e.is_in_group("npc"):
		if ! e.follow:
			e.apply_impulse(Vector3(0.0, 0.0, 0.0), get_global_transform().basis[2] * 2)
			e.follow = true
			e._set_player(self)
	else:
		do_grabkill(e)
#		if e.ko:
#			do_grabkill(e)
#		else:
#			if randi() % 3 == 2:
#				e.ko = false
#				e.enemy = false
#				e.add_to_group("npc")
#				e.remove_from_group("enemies")
#				e.npc = true
var attack_delay = 0.0
func do_chase(delta):
	var pt = game_player.get_transform()
	var ppos = pt.origin
	var npct = get_transform()
	set_transform(npct.looking_at(ppos, upv))
	if get_linear_velocity().length() < 40 + strength / 10 and !sight.is_colliding():
		apply_impulse(Vector3(0.0, 0.0, 0.0), (ppos - npct.origin).normalized() * 500 * delta + upv * 250 * delta)

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
func enemy_state_grabkill(delta):
	pass
func enemy_state_grabkilled(delta):
	anim.do_grabkilled()
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
				if sight.is_colliding():
					var f = sight.get_collider()
					if f.is_in_group("npc"):
						do_grab(f)
					if f.is_in_group("enemies"):
						do_grab(f)
	elif dead:
		if Input.is_action_pressed("pl_attack"):
			health = max_health / 2
			dead = false
			ko = false
			anim.reset()
			anim.recompute_caches()
	if immortal:
		ko = false

func player_state_grabkill(delta):
	anim.do_grabkill()
	if Input.is_action_pressed("pl_attack"):
		switch_state(STATE_NORMAL)
func run_state(delta):
	if state == STATE_NORMAL:
		if enemy:
			enemy_state_normal(delta)
		elif player:
			player_state_normal(delta)
		elif npc:
			npc_state_normal(delta)
		if attack:
			anim.reset()
			anim.recompute_caches()
			attack = false
		var rv = get_linear_velocity()
		if rv.length() > 10:
			set_linear_velocity(rv.normalized() * 6)
		if can_move():
			var tv = get_linear_velocity()
			tv.y = 0
			if tv.length() > 0.2:
				anim.do_walk(tv.length())
			else:
				anim.do_stop()
		if score > next_score:
			level = level + 1
			next_score = next_score + pow(score, 2) / 50
			max_health = max_health + 1
			health = max_health
			strength = strength + 1
	elif state == STATE_GRABKILL:
		if player:
			player_state_grabkill(delta)
	elif state == STATE_GRABKILLED:
		if enemy:
			enemy_state_grabkilled(delta)
		elif npc:
			npc_state_grabkilled(delta)
func _fixed_process(delta):
	var lv = get_linear_velocity()
#	if sight.is_colliding():
#		print(get_name(), " sight:", sight.is_colliding())
#		print(sight.get_collider())
	run_state(delta)
	if is_sleeping():
		set_sleeping(false)
