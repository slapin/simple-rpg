
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_fixed_process(true)

func _fixed_process(dt):
	var vel = get_linear_velocity()
	vel.y = 0
	if Input.is_action_pressed("pl_forward") and vel.length() < 1.5:
		apply_impulse(Vector3(0.0, 0.0, 0.0), get_mass() * get_transform().basis[2] + Vector3(0.0, get_mass() / 3, 0.0))
	elif Input.is_action_pressed("pl_back") and vel.length() < 1.5:
		apply_impulse(Vector3(0.0, 0.0, 0.0), -get_mass() * get_transform().basis[2] + Vector3(0.0, get_mass() / 3, 0.0))
#	else:
#		set_linear_velocity(Vector3(0.0, 0.0, 0.0))
	if Input.is_action_pressed("pl_left"):
		set_transform(get_transform().rotated(Vector3(0.0, 1.0, 0.0), -2.9 * dt))
#		set_rotation(get_rotation() + Vector3(0.0, -0.5 * dt, 0.0))
	if Input.is_action_pressed("pl_right"):
		set_transform(get_transform().rotated(Vector3(0.0, 1.0, 0.0), 2.9 * dt))
#		set_rotation(get_rotation() + Vector3(0.0, 0.5 * dt, 0.0))

