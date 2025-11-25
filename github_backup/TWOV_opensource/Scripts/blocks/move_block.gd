extends RigidBody2D

var jump_force = 1800

func action(params: Dictionary) -> void:
	if params.has("repulsive"):
		if params["repulsive"]["force_x"] == true:
			apply_central_impulse(sign(Vector2(global_position.x - params["repulsive"]["position"].x, 0.0)) * 80 * params["repulsive"]["force"])
		if params["repulsive"]["force_y"] == true:
			apply_central_impulse(sign(Vector2(0.0, global_position.y - params["repulsive"]["position"].y)) * 80 * params["repulsive"]["force"])
	elif params.has("gravity_change"):
		if gravity_scale > 0:
			gravity_scale = params["gravity_change"]["force_gravity"] * 5
		else:
			gravity_scale = -params["gravity_change"]["force_gravity"] * 5
