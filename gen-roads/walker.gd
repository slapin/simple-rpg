
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	set_fixed_process(true)
func _fixed_process(dt):
	var ph = get_linear_velocity()
	var phd = Vector3(ph.x, 0.0, ph.z)
	if Input.is_action_pressed("pl_forward"):
		if phd.length() < 5:
			apply_impulse(Vector3(0.0, 0.0, 0.0), get_transform().basis[2] * 0.5 * get_mass() + Vector3(0.0, 7.0, 0.0))
	if Input.is_action_pressed("pl_left"):
			var pv = get_transform().rotated(Vector3(0.0, 1.0, 0.0), -1.5 * dt)
			set_transform(pv)
	elif Input.is_action_pressed("pl_right"):
			var pv = get_transform().rotated(Vector3(0.0, 1.0, 0.0), 1.5 * dt)
			set_transform(pv)
	if Input.is_action_pressed("pl_jump"):
			apply_impulse(Vector3(0.0, 0.0, 0.0), get_transform().basis[1] * 2000.0 * dt)
	



