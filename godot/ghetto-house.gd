
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
			doors.append({"door_mesh":n})
			break
	for i in n.get_children():
		find_doors(i)


func find_windows(n):
	var i
	for i in range(0, 10):
		if n.get_name().begins_with("Window"):
			n.set_draw_range_end(20.0)
	for i in n.get_children():
		find_windows(i)

func _ready():
	# Initialization here
#	var mh = DirectionalLight.new()
#	var nc = Camera.new()
	var n
	for n in get_children():
		find_doors(n)
	print(doors)
	for n in get_children():
		find_windows(n)

	
#	add_child(mh)
#	add_child(nc)
#	mh.look_at_from_pos(Vector3(10.0, 3.0, 25), Vector3(), Vector3(0.0, 1.0, 0.0))
#	nc.look_at_from_pos(Vector3(0.0, 8.0, 15), Vector3(), Vector3(0.0, 1.0, 0.0))
	
	var d
	var door_transforms = []
	for f in doors:
		var b = KinematicBody.new()
#		b.set_mass(20)
#		b.set_mode(b.MODE_KINEMATIC)
		var t = f["door_mesh"].get_global_transform()
		var aabb = f["door_mesh"].get_aabb()
		add_child(b)
		b.set_global_transform(t)
		f["door_mesh"].get_parent().remove_child(f["door_mesh"])
		b.add_child(f["door_mesh"])
		f["door_mesh"].set_draw_range_end(20.0)
		var shp = BoxShape.new()
		shp.set_extents(aabb.size/2.0)
		var shp2 = BoxShape.new()
		var xtents = aabb.size / 2.0
		xtents.z = xtents.z * 3.0
		xtents.y = xtents.y * 3.0
		shp2.set_extents(xtents)
#		print(" pos:", aabb.pos, " size:", aabb.size, " end:", aabb.end)
#		b.add_shape(shp, Transform().translated(Vector3(0.0, -aabb.size.y / 2.0, 0.0)))
#		b.add_shape(shp, Transform().translated(Vector3(0.0, -aabb.size.y / 2.0, 0.0)))
#		b.add_shape(shp2, Transform().translated(Vector3(0.0, -aabb.size.y / 2.0, 0.0)))
		b.add_shape(shp, Transform().translated(Vector3(0.0, aabb.size.y / 1.0, 0.0)))
		b.add_shape(shp2, Transform().translated(Vector3(0.0, aabb.size.y / 1.0, 0.0)))
#		b.set_shape_transform(0, t * b.get_transform().inverse())
#		b.set_shape_transform(1, t * b.get_transform().inverse())
		b.set_shape_as_trigger(1, true)
		b.set_as_toplevel(true)
		b.set_collide_with_character_bodies(true)
		b.set_collide_with_kinematic_bodies(false)
		b.set_collide_with_rigid_bodies(true)
		b.set_collide_with_static_bodies(true)
		f["door_body"] = b
		f["door_transform"] = b.get_transform()
#		door_bodies.append(b)
#		door_transforms.append(b.get_transform())
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
	for g in doors:
		if g["door_body"].is_colliding():
			var m = g["door_body"].get_collider()
			if m.is_in_group("characters"):
				print(m.get_name())
				g["door_body"].set_transform(g["door_transform"].rotated(Vector3(0.0, PI/2.0, 0.0)))
		if movedelay < 0.0:
#			g.move(Vector3(0.1, 0.0, 0.1))
			var r = g["door_body"].get_rotation()
#			g["door_body"].set_rotation(Vector3(r.x, r.y + PI/2.0, r.z))
			movedelay = 1.0
		else:
			movedelay -= delta
