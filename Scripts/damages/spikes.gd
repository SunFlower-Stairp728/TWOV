extends Node2D

var body_on_spikes = false
var current_body = null

func _process(_delta):
	if body_on_spikes and Global.invicible == 0 and Global.pause == 0 and Global.animation == 0:
		if Global.game_data["player"].size() > 0:
			if current_body.global_position.y < self.global_position.y:
				current_body.action({"damage": {"amount": randi_range(5, 8)}}, "action")
				current_body.velocity.y = -500.0
			else:
				current_body.action({"damage": {"amount": Global.game_data["player"]["health_human"]}}, "action")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body_on_spikes = true
		current_body = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		body_on_spikes = false
		current_body = null
