
extends RayCast

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	set_process(true)

var ch = null
var npc = false
var enemy = false
var player = false

var orders_enabled = false
func _process(delta):
	if is_colliding():
		var col = get_collider()
		if col.is_in_group("characters"):
			ch = col
			if col.npc:
				npc = true
			elif col.enemy:
				enemy = true
			elif col.player:
				player = true
		else:
			ch = null
			npc = false
			enemy = false
			player = false

func process_orders(pl):
	if is_colliding() and not orders_enabled:
		if npc:
			get_tree().call_group(0, "gui", "show_orders", get_collider())
			ch._set_player(pl)
			orders_enabled = true
	elif orders_enabled:
		get_tree().call_group(0, "gui", "show_orders", get_collider())
		orders_enabled = false


