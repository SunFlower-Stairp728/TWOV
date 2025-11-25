extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		var current_scene_name = get_tree().current_scene.scene_file_path.get_file().to_lower()
		var level_num = int(current_scene_name.trim_prefix("level_").trim_suffix(".tscn"))
		var name_effect = Global.effect_list.get(level_num, ["block meat"])
		
		Global.index += 1
		Global.effects.emit(name_effect, Global.index)
		queue_free()
