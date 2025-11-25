extends CharacterBody2D

enum type {platform, pinball}
@export var type_platform = type.platform

enum action_status {idle, move, broke}
var state = action_status.idle

var current_body = null

var direction = Vector2(0, -1)
var speed = 200

@onready var animation = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if state == action_status.move:
		position += speed * direction * delta

func platform_action(_action: Dictionary):
	if _action["action"]["type"] == "move":
		direction = _action["action"]["direction"]
		state = action_status.move
	elif _action["action"]["type"] == "broke":
		state = action_status.broke
	elif _action["action"]["type"] == "stop":
		state = action_status.idle

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("action"):
		if state == action_status.move:
			current_body = body
		elif state == action_status.broke:
			animation.play("fall")
		if type_platform == type.pinball:
			body.action({"repulsive": {"position": global_position, "force_x": true, "force_y": true, "force": randi_range(9, 12), "wait": true}}, "action")
			if animation.current_animation != "fall":
				animation.play("pin")
