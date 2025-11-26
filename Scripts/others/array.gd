extends TextureRect

var damage_count = 0
var speed = 8.0

@onready var level = get_node("/root/level_2/Window/level_2")

func _process(_delta: float) -> void:
	if Global.pause != 0:
		return
	
	position.y -= speed * 1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	damage_count += 1
	if damage_count == 1:
		level.damage(5.0)
		queue_free()
