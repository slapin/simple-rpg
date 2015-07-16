
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

var doors = []
var rdoors = []
func find_doors(n):
	var i
	for i in range(0, 10):
		if n.get_name() == "door" + str(i):
			doors.append(n)
			break
	for i in n.get_children():
		find_doors(i)

var door_bodies = []

func _ready():
	# Initialization here
#	var mh = DirectionalLight.new()
#	var nc = Camera.new()
	var n
	for n in get_children():
		find_doors(n)
	print(doors)
#	add_child(mh)
#	add_child(nc)
#	mh.look_at_from_pos(Vector3(10.0, 3.0, 25), Vector3(), Vector3(0.0, 1.0, 0.0))
#	nc.look_at_from_pos(Vector3(0.0, 8.0, 15), Vector3(), Vector3(0.0, 1.0, 0.0))
	
	var d
	for f in doors:
		var b = KinematicBody.new()
#		b.set_mass(20)
#		b.set_mode(b.MODE_KINEMATIC)
		var t = f.get_global_transform()
		var aabb = f.get_aabb()
		add_child(b)
		b.set_global_transform(t)
		f.get_parent().remove_child(f)
		b.add_child(f)
		var shp = BoxShape.new()
		shp.set_extents(aabb.size/2.0)
		var shp2 = BoxShape.new()
		shp2.set_extents(aabb.size / 2.0 * 1.2)
		print(" pos:", aabb.pos, " size:", aabb.size, " end:", aabb.end)
#		b.add_shape(shp, Transform().translated(Vector3(0.0, -aabb.size.y / 2.0, 0.0)))
#		b.add_shape(shp, Transform().translated(Vector3(0.0, -aabb.size.y / 2.0, 0.0)))
#		b.add_shape(shp2, Transform().translated(Vector3(0.0, -aabb.size.y / 2.0, 0.0)))
		b.add_shape(shp, Transform().translated(Vector3(0.0, aabb.size.y / 1.0, 0.0)))
#		b.add_shape(shp2, Transform().translated(Vector3(0.0, aabb.size.y / 1.0, 0.0)))
#		b.set_shape_transform(0, t * b.get_transform().inverse())
#		b.set_shape_transform(1, t * b.get_transform().inverse())
#		b.set_shape_as_trigger(1, true)
		b.set_as_toplevel(true)
		b.set_collide_with_character_bodies(true)
		b.set_collide_with_kinematic_bodies(false)
		b.set_collide_with_rigid_bodies(true)
		b.set_collide_with_static_bodies(true)
		door_bodies.append(b)
#		b.set_max_contacts_reported(1)
#		b.set_contact_monitor(true)
#		
#		b.connect("body_enter", self, "_enter")
#		b.connect("body_exit", self, "_exit")
#		var joint1 = HingeJoint.new()
#		var joint2 = HingeJoint.new()
#		add_child(joint1)
#		add_child(joint2)
#		joint1.set_rotation(Vector3(-90.0, 0.0, 0.0))
#		joint1.global_translate(t.origin + Vector3(aabb.size.x/2, 0.0, 0.0))
#		joint1.set_node_a(b.get_path())
#		joint1.set_node_b(get_path())
#		joint2.set_rotation(Vector3(-90.0, 0.0, 0.0))
#		joint2.global_translate(t.origin + Vector3(0.0, 1.0, 0.0) + Vector3(aabb.size.x/2, 0.0, 0.0))
#		joint2.set_node_a(b.get_path())
#		joint2.set_node_b(get_path())
	set_fixed_process(true)
func _enter(body):
	if body.is_in_group("characters"):
		print(body.get_name())
func _exit(body):
	pass

var movedelay = 1.0
func _fixed_process(delta):
	for g in door_bodies:
		if g.is_colliding():
			var m = g.get_collider()
			if m.is_in_group("characters"):
				print(m.get_name())
		if movedelay < 0.0:
#			g.move(Vector3(0.1, 0.0, 0.1))
			var r = g.get_rotation()
			g.set_rotation(Vector3(r.x, r.y + PI/2.0, r.z))
			movedelay = 1.0
		else:
			movedelay -= delta
