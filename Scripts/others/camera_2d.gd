extends Camera2D

var max_dist = -2000.0
var tween
var speed_move = 1.3
var speed_zoom = 0.9
var camera_move = false
var time_press = 0.0
var zoom_start = 1.5

@onready var player = get_node("/root/level_2/player") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/player") if Global.type_level == "menu" else null

func _process(delta):
	if Input.is_action_pressed("ui_zoom") and player.velocity == Vector2(0.0, 0.0):
		if camera_move == false:
			time_press += delta
			print(time_press)
			if time_press >= zoom_start:
				camera_move = true
				time_press = 0.0
				tween = create_tween()
				tween.tween_property(self, "position", Vector2(0.0, max_dist), speed_move)
	elif Input.is_action_just_released("ui_zoom"):
		time_press = 0.0
		await get_tree().create_timer(1.2).timeout
		camera_move = false
		tween = create_tween()
		tween.tween_property(self, "position", Vector2(0.0, 0.0), speed_move)
