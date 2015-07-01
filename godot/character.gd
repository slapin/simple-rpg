
extends RigidBody

export var enemy = false
export var player = false
export var mass = 70
export var strength = 10
export var health = 100

var max_health
var dead = false
var ko = false

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
	health -= damage
	if health > 0 and damage > strength * 3:
		ko = true
		print("ko")
		anim.reset()
		anim.do_ko()
	var dtest = 10 + randi() % strength
	if dtest < 0:
		dtest = 0
	if health < dtest:
		ko = true
		print("ko")
		anim.reset()
		anim.do_ko()
	if health < 0:
		health = 0
		dead = true
		print("dead")
		anim.reset()
		anim.do_die()
	if player:
		get_tree().call_group(0, "gui", "set_health", health)
func punch(c):
	c.punched(self, randi() % strength + strength / 10)
	score += 1

func _ready():
	max_health = health
	set_mode(self.MODE_CHARACTER)
	down = get_node("down")
	down.set_enabled(true)
	if enemy:
		add_to_group("enemies")
	if not enemy and not player:
		add_to_group("bystanders")
	add_to_group("characters")
	anim = get_node("anim")
	animp = get_node("man/AnimationPlayer")
	sight = get_node("sight")
	skel = get_node("man/711man/Skeleton")
	hip_attach = HipsSphere.new(self)
	skel.add_child(hip_attach)
	var meshi = get_node("man/711man/Skeleton/pants")
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
var attack_delay = 0.0
func _fixed_process(delta):
	var lv = get_linear_velocity()
#	if sight.is_colliding():
#		print(get_name(), " sight:", sight.is_colliding())
#		print(sight.get_collider())
	if not player:
		if game_player != null and can_move():
			var pt = game_player.get_transform()
			var ppos = pt.origin
			var npct = get_transform()
			set_transform(npct.looking_at(ppos, upv))
			if get_linear_velocity().length() < 40 and !sight.is_colliding():
				apply_impulse(Vector3(0.0, 0.0, 0.0), (ppos - npct.origin).normalized() * 500 * delta + upv * 250 * delta)
			if !attack_delay > 0.0:
				if sight.is_colliding():
					var c = sight.get_collider()
					if c.is_in_group("enemies"):
						if enemy:
							if randi() % 10 > 1:
								do_attack(c, 300)
								coltrig = true
					elif c.is_in_group("characters"):
						if enemy:
							do_attack(c, 600)
						attack_delay = 1.0
			else:
				attack_delay -= delta
	elif can_move():
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
	elif dead and player:
		if Input.is_action_pressed("pl_attack"):
			health = max_health / 2
			dead = false
			ko = false
			anim.reset()
			anim.recompute_caches()
	if attack:
		anim.reset()
		anim.recompute_caches()
		attack = false
	var rv = get_linear_velocity()
	if rv.length() > 10:
		set_linear_velocity(rv.normalized() * 6)
	if is_sleeping():
		set_sleeping(false)
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
		
