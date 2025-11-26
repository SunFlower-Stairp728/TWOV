extends Node2D


@onready var main_level = get_node("/root/level_2") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2") if Global.type_level == "menu" else null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		var current_scene_name = get_tree().current_scene.scene_file_path.get_file().to_lower()
		var level_num = int(current_scene_name.trim_prefix("level_").trim_suffix(".tscn"))
		var boss_name = Global.boss_list_name.get(level_num, "stasik")
		
		var path = {
			"type": "arena",
			"name_fight": boss_name,
			"animation": true
		}
		
		main_level.fight(path)
		queue_free()
