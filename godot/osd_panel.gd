
extends Panel

# member variables here, example:
# var a=2
# var b="textvar"
var health_data
var fps_data
var order
var target = null
func set_orders():
	var orp = order.get_popup()
	orp.clear()
	orp.add_item("\"Follow\"")
	orp.add_item("Grab")
	orp.add_item("\"Get lost\"")
	orp.connect("item_pressed", self, "_order")
func _ready():
	# Initialization here
	health_data = get_node("health/health_data")
	fps_data = get_node("fps/fps_data")
	order = get_node("order")
	order.connect("about_to_show", self, "_popup_show")
	set_orders()
	order.hide()
	add_to_group("gui")
	set_process(true)

func set_health(health):
	health_data.set_text(str(health))

func _process(delta):
	fps_data.set_text(str(OS.get_frames_per_second()))

func _order(id):
	print("selected item: ", id)
	get_tree().set_pause(false)
	if target != null:
		if id == 0:
			target.set_follow(true)
		elif id == 1:
			target.game_player.do_grabkill(target)
		elif id == 2:
			target.set_follow(false)
	order.hide()

func _popup_show():
	get_tree().set_pause(true)
func show_orders(col):
	order.show()
	target = col
func hide_orders(col):
	order.hide()
	target = null
