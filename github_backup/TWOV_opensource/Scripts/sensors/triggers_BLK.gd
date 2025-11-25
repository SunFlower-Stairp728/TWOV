extends Node2D
enum type_action {broke, stop, move}

@export var action = type_action.move
@export var direction_change = Vector2(0, 1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("platform_action"):
		if action == type_action.move:
			body.platform_action({"action": {"type": "move", "direction": direction_change}})
		elif action == type_action.broke:
			body.platform_action({"action": {"type": "broke"}})
		elif action == type_action.stop:
			body.platform_action({"action": {"type": "stop"}})
