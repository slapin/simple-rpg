
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"
var rpg_stats = {}
var player_characters = [
	{
		"name": "Alex",
		"class": "Fighter",
		"act": {
			"health": 100,
			"magic": 100,
		},
		"max": {
			"health": 100,
			"magic": 100,
		},
		"place": 0,
		"row": 0,
		"model": 0,
	},
	{
		"name": "Pot",
		"class": "Fighter",
		"act": {
			"health": 100,
			"magic": 100,
		},
		"max": {
			"health": 100,
			"magic": 100,
		},
		"place": 1,
		"row": 0,
		"model": 0,
	},
	{
		"name": "Bulk",
		"class": "Fighter",
		"act": {
			"health": 100,
			"magic": 100,
		},
		"max": {
			"health": 100,
			"magic": 100,
		},
		"place": 2,
		"row": 0,
		"model": 0,
	},
]


var enemy_characters = [
	{
		"name": "Axis",
		"class": "Fighter",
		"act": {
			"health": 100,
			"magic": 100,
		},
		"max": {
			"health": 100,
			"magic": 100,
		},
		"place": 0,
		"row": 0,
		"model": 0,
	},
	{
		"name": "Zoe",
		"class": "Fighter",
		"act": {
			"health": 100,
			"magic": 100,
		},
		"max": {
			"health": 100,
			"magic": 100,
		},
		"place": 1,
		"row": 0,
		"model": 0,
	},
	{
		"name": "Ant",
		"class": "Fighter",
		"act": {
			"health": 100,
			"magic": 100,
		},
		"max": {
			"health": 100,
			"magic": 100,
		},
		"place": 3,
		"row": 0,
		"model": 0,
	},
	{
		"name": "Wtf",
		"class": "Fighter",
		"act": {
			"health": 100,
			"magic": 100,
		},
		"max": {
			"health": 100,
			"magic": 100,
		},
		"place": 5,
		"row": 1,
		"model": 0,
	},
]
func create_text_label(text):
	var l = Label.new()
	l.set_text(text)
	return l

func create_stat_num(text, val_act, val_max):
	var h = HBoxContainer.new()
	var l = create_text_label(text)
	h.add_child(l)
	l = create_text_label(str(val_act) + "/" + str(val_max))
	h.add_child(l)
	return h
func create_stat_text(text, value):
	var h = HBoxContainer.new()
	var l = create_text_label(text)
	h.add_child(l)
	l = create_text_label(value)
	h.add_child(l)
	return h
func create_char_stat_view(data):
	var v = VBoxContainer.new()
	v.add_child(create_stat_text("Name", data["name"]))
	v.add_child(create_stat_num("Health", data["act"]["health"], data["max"]["health"]))
	v.add_child(create_stat_num("Mana", data["act"]["magic"], data["act"]["magic"]))
	return v
var _rp = 0
var _rr = 0
var _rs = 0
var models = [load("res://711char.scn")]


func _on_action(act):
	print(act)
	if act == "attack":
		sel2.get_sel_node().attack(sel1.get_sel_node())
	elif act == "spell":
		sel2.get_sel_node().spell(sel1.get_sel_node())
	elif act == "capture":
		sel2.get_sel_node().capture(sel1.get_sel_node())
	sel2.next_char()
	var selector_node = sel2.get_sel_node()
	while sel2.is_enemy():
		selector_node.ai_turn(sel1.get_random_char())
		sel2.next_char()
		selector_node = sel2.get_sel_node()

class Charsel extends Spatial:
	var char_pos_index = 0
	var curchar
	var characters
	var enemy = false

	func update_transform():
		var cgt = curchar.get_global_transform()
		set_translation(Vector3(cgt.origin.x, 0.0, cgt.origin.z))
		set_scale(Vector3(1.1, 1.1, 1.1))
	func next_char():
		if characters.size() <= 0:
			return
		char_pos_index += 1
		if char_pos_index >= characters.size():
			char_pos_index = 0
		curchar = characters[char_pos_index]
		update_transform()

	func prev_char():
		if characters.size() <= 0:
			return
		char_pos_index -= 1
		if char_pos_index < 0:
			char_pos_index = characters.size() - 1
		curchar = characters[char_pos_index]
		update_transform()
	func get_sel_node():
		return curchar
	func is_enemy():
		return curchar.enemy
	func get_random_char():
		return characters[randi() % characters.size()]
	func add_char(data):
		characters.append(data)
	func _init(data):
		if data["characters"].size() > 0:
			curchar = data["characters"][0]
		else:
			curchar = null
		characters = data["characters"]
		if characters.size() > 0:
#			while ! enemy == is_enemy():
#				next_char()
			update_transform()
class SelGrid extends Area:
	var box
	var position
	var active
	var ptr
	var pointer
	func _input_data(cam, evt, pos, normal, shape):
		var ipos = Vector3(int(pos.x) & ~1, int(pos.y) & ~1, int(pos.z) & ~1)
		if not active:
			return
		if evt.type == InputEvent.MOUSE_MOTION:
			position = ipos
			if pointer.is_hidden():
				pointer.show()
		elif evt.is_action("act"):
			print("pos: ", pos, " evt: ", evt)
			active = false
			position = ipos
			pointer.hide()
			set_ray_pickable(false)
			print(position)
		update_place()
	func activate():
		active = true
		set_ray_pickable(true)
	func update_place():
		ptr.set_translation(position)
	func set_pointer(obj):
		pointer = obj
		pointer.hide()
		ptr.add_child(pointer)
	func _init():
		box = BoxShape.new()
		box.set_extents(Vector3(1.0, 0.3, 1.0))
		var xaxis = Vector3(1.0, 0.0, 0.0)
		var yaxis = Vector3(0.0, 1.0, 0.0)
		var zaxis = Vector3(0.0, 0.0, 1.0)
		ptr = Spatial.new()
		add_child(ptr)
		var i
		var j
		for i in range(-12, 13, 2):
			for j in range(-10, 20, 2):
				var T = Transform(xaxis, yaxis, zaxis, Vector3(i, 0.3, j))
				add_shape(box, T)
		active = true
		position = Vector3(0.0, 0.0, 0.0)
		connect("input_event", self, "_input_data")
		set_ray_pickable(true)
		set_enable_monitoring(true)
		
var sel1
var sel2
var selgrid
var sel_data = {
	"characters": [],
}
func spawn_char(ch, ep):
	var h = preload("res://char.gd").new(ch, ep, models[ch["model"]])
	add_child(h)
	h.spawn()
	sel_data["characters"].append(h)

var arrow
var arrow2
var selector
func _ready():
#	var data = File.new()
	print("aa")
	var buttons = get_node("buttons")
	var h = HBoxContainer.new()
	var i = 0
	for p in player_characters:
		var v = create_char_stat_view(p)
		h.add_child(v)
	buttons.add_child(h)
	h.set_pos(Vector2(0, 40))
	var b = get_node("buttons/buttons/attack")
	b.connect("pressed", self, "_on_action", ["attack"])
	b = get_node("buttons/buttons/spell")
	b.connect("pressed", self, "_on_action", ["spell"])
	b = get_node("buttons/buttons/inventory")
	b.connect("pressed", self, "_on_action", ["inventory"])
	b = get_node("buttons/buttons/capture")
	b.connect("pressed", self, "_on_action", ["capture"])
	arrow = preload("res://pointer.scn").instance()
	arrow2 = preload("res://pointer.scn").instance()
	selector = preload("res://selector.scn").instance()
#instancing player party
	var cp
	for cp in player_characters:
		spawn_char(cp, 0)
#instancing enemy party
	for cp in enemy_characters:
		spawn_char(cp, 1)
	selgrid = SelGrid.new()
	sel1 = Charsel.new(sel_data)
	sel1.add_child(arrow)
	sel1.enemy = false
	sel2 = Charsel.new(sel_data)
	sel2.add_child(selector)
	sel2.enemy = true
	selgrid = SelGrid.new()
	add_child(sel1)
	add_child(sel2)
	selgrid.set_pointer(arrow2)
	add_child(selgrid)
	print("bb")
	set_process(true)
	
	
	
#	data.open("res://stats.json", 1)
#	rpg_stats.parse_json(data.get_as_text())
#	data.close()
#	data.free()

var move_delay = 0.15
var move_time = 0.0



func _process(delta):
	var moved = false
	if not sel2.is_enemy():
		if Input.is_action_pressed("arrow_near") and move_time > move_delay:
			sel1.next_char()
			moved = true
		if Input.is_action_pressed("arrow_far") and move_time > move_delay:
			sel1.prev_char()
			moved = true
		arrow.show()
	else:
		moved = false
		arrow.hide()
	if moved:
		move_time = 0.0
		moved = false
		print(arrow.get_global_transform().origin)
	else:
		move_time = move_time + delta
