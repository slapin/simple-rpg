extends RigidBody
export var mass = 70
export var strength = 10
export var health = 100
export var immortal = false
export var enemy = false
export var player = false

var max_health
var score = 0
var next_score
var level = 0
var love = 0
var fear = 0
var hate = 0

var game_player = null

func _set_player(pl):
	game_player = pl
#for now, set all non-player
#char attention to player
# but later this can be changed individually
	set_attention(pl)


var dead = false
var ko = false
var npc = false
var tripped = false
var follow = false
var chase = false

const STATE_NORMAL = 0
const STATE_GRABKILL = 1
const STATE_GRABKILLED = 2
const STATE_KO = 3
const STATE_ACTION = 4
const STATE_DEAD = 5
const STATE_TRIPPED = 6
var state = STATE_NORMAL
var attn_obj

var state_to_text = {
	STATE_NORMAL: "normal",
	STATE_GRABKILL: "grabkill",
	STATE_GRABKILLED: "grabkilled",
	STATE_KO: "ko",
	STATE_ACTION: "action",
	STATE_DEAD: "dead",
	STATE_TRIPPED: "tripped",
}

var text_to_state = {
	"normal": STATE_NORMAL,
	"grabkill": STATE_GRABKILL,
	"grabkilled": STATE_GRABKILLED,
	"ko": STATE_KO,
	"action": STATE_ACTION,
	"dead": STATE_DEAD,
	"tripped": STATE_TRIPPED,
}

const upv = Vector3(0.0, 1.0, 0.0)

var sight

func _ready():
	print(get_filename() + " _ready")
	max_health = health
	next_score = 10
	set_mode(self.MODE_CHARACTER)
	sight = get_node("sight")
	set_fixed_process(true)
	set_process(true)

func _process(delta):
	pass

func common_state_normal(delta):
	if score > next_score:
		level = level + 1
		next_score = next_score + pow(score, 2) / 50
		max_health = max_health + 1
		health = max_health
		strength = strength + 1
		fear = 0

func set_attention(obj):
	attn_obj = obj

func do_avoid(delta):
	var pt = attn_obj.get_transform()
	var ppos = pt.origin
	var npct = get_transform()
	set_transform(npct.looking_at(ppos, upv))
	
	if get_linear_velocity().length() < 15 + strength / 10 and (ppos - npct.origin).length() < 5:
		apply_impulse(Vector3(0.0, 0.0, 0.0), -((ppos - npct.origin).normalized() * 500 * delta + upv * 250 * delta) * 4)
		if randi() % 100 == 3:
			switch_state(STATE_TRIPPED)

func do_chase(delta):
	var pt = attn_obj.get_transform()
	var ppos = pt.origin
	var npct = get_transform()
# we really don't want to rotate whole character
# body in direction of player
	set_transform(npct.looking_at(Vector3(ppos.x, npct.origin.y, ppos.z), upv))
	if get_linear_velocity().length() < 40 + strength / 10 and !sight.is_colliding():
		apply_impulse(Vector3(0.0, 0.0, 0.0), (ppos - npct.origin).normalized() * 500 * delta + upv * 250 * delta)


func switch_state(newstate):
	if typeof(newstate) == TYPE_STRING:
		newstate = text_to_state[newstate]
	if newstate != state:
		if has_method(state_to_text[state] + "_to_" + state_to_text[newstate]):
			call(state_to_text[state] + "_to_" + state_to_text[newstate])
		if has_method("switch_from_" + state_to_text[state]):
			call("switch_from_" + state_to_text[state], newstate)
		if has_method("switch_to_" + state_to_text[newstate]):
			call("switch_to_" + state_to_text[newstate], state)
		state = newstate


func run_state(delta):
	var rf
	if enemy:
		rf = "enemy_state_" + state_to_text[state]
	elif player:
		rf = "player_state_" + state_to_text[state]
	elif npc:
		rf = "npc_state_" + state_to_text[state]
	if has_method(rf):
		call(rf, delta)
	rf = "common_state_" + state_to_text[state]
	if has_method(rf):
		call(rf, delta)
func _fixed_process(delta):
	run_state(delta)
	if is_sleeping():
		set_sleeping(false)

func can_move():
	if not ko and not dead and not tripped:
		return true
	else:
		return false

func punched(c, dam):
	var defence = strength / 10
	var damage = dam / (defence + 1)
	if ! immortal:
		health -= damage
	if health > 0 and damage > strength * 3:
		switch_state(STATE_KO)
	var dtest = 10 + randi() % strength
	if dtest < 0:
		dtest = 0
	if health < dtest:
		switch_state(STATE_KO)
	if health < 0:
		health = 0
		dead = true
		switch_state(STATE_DEAD)
	if c.health > health:
		fear += (damage + (c.health - health)) / strength + 1
	else:
		fear += damage  / strength + 1
	hate += randi() % ((damage + fear) / strength + 1)
	if npc:
		fear += (strength + c.strength) * 2
		hate += damage / 10
	
	if player:
		get_tree().call_group(0, "gui", "set_health", health)
	if dead:
		print("DEAD")

func punch(c):
	if !c.dead:
		c.punched(self, randi() % strength + strength / (10 + fear))
		score += 1
		if c.dead:
			score += (c.strength * c.level) / (level + 1) + 1

func resurrect():
	health = max_health / 2
	ko = false
	dead = false
	tripped = false
	switch_state(STATE_NORMAL)
