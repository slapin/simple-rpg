
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"
var blink
var walk
var kneel
var anim

func _ready():
	# Initialization here
	blink = get_node("blink")
	blink.connect("pressed", self, "do_blink")
	walk = get_node("walk")
	walk.connect("pressed", self, "do_walk")
	kneel = get_node("kneel")
	kneel.connect("pressed", self, "do_kneel")
	anim = get_node("AnimationTreePlayer")

func do_blink():
	anim.do_blink()
func do_walk():
	anim.do_walk()
func do_kneel():
	anim.do_kneel()
