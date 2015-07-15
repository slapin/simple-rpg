
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



