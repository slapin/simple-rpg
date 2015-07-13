
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

var bus
var buscol
var wheel1
var wheel2
var wheel3
var wheel4
var door1
var door2
var door3

func _ready():
	bus = get_node("bus/bus")
	buscol = get_node("buscol")
	wheel1 = get_node("bus/bus/wheel1")
	wheel2 = get_node("bus/bus/wheel2")
	wheel3 = get_node("bus/bus/wheel3")
	wheel4 = get_node("bus/bus/wheel4")
	wheel1.set_suspension_stiffness(15000.0)
	wheel1.set_suspension_max_force(12000)
	wheel1.set_suspension_travel(2.0)
	wheel1.set_use_as_traction(true)
	wheel1.set_use_as_steering(true)
	wheel2.set_suspension_travel(2.0)
	wheel2.set_suspension_stiffness(15000.0)
	wheel2.set_suspension_max_force(12000)
	wheel2.set_use_as_traction(true)
	wheel3.set_suspension_stiffness(15000.0)
	wheel3.set_suspension_max_force(12000)
	wheel3.set_suspension_travel(2.0)
	wheel3.set_use_as_traction(true)
	wheel3.set_use_as_steering(true)
	wheel4.set_suspension_stiffness(15000.0)
	wheel4.set_suspension_max_force(12000)
	wheel4.set_suspension_travel(2.0)
	wheel4.set_use_as_traction(true)
	var t
	var d1 = RigidBody.new()
	door1 = get_node("bus/bus/door1")
	door2 = get_node("bus/bus/door2")
	door3 = get_node("bus/bus/door3")
	var t = door1.get_translation()
	bus.set_mass(4000)
#	buscol.set_mass(40)
	bus.remove_child(door1)
	bus.add_child(d1)
	d1.set_translation(t)
	d1.add_child(door1)
	var ch
	var bust = bus.get_transform()
	print("ch")
	for ch in range(0, buscol.get_shape_count()):
		var sh = buscol.get_shape(ch)
		var t = buscol.get_shape_transform(ch)
		bus.add_shape(sh, t.rotated(Vector3(0.0, 1.0, 0.0), PI))
	buscol.get_parent().remove_child(buscol)
	buscol.queue_free()

	
	set_process(true)
func _process(delta):
	bus.set_engine_force(randf() * 5000)
	
	


