extends Node2D

@onready var key_sound = $key_sound
@onready var door = get_node("/root/level_2/door") if Global.type_level == "level_2" else null

var key_taken = false
var tween : Tween

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and key_taken == false:
		key_taken = true
		key_sound.play()
		tween = create_tween()
		tween.tween_property(self, "global_position", Vector2(door.position.x + 80.0, door.position.y + 100.0), self.global_position.distance_to(door.global_position) / 200.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		tween = create_tween()
		tween.tween_property(self, "rotation", 0.63, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		tween = create_tween()
		tween.tween_property(self, "global_position", Vector2(door.position.x, door.position.y + 100.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		door.get_node("AnimationPlayer").play("open")
		door.enter = true
		queue_free()
