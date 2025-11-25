extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		Global.gui_window = 1
		var current_scene_name = get_tree().current_scene.scene_file_path.get_file().to_lower()
		var level_num = int(current_scene_name.trim_prefix("level_").trim_suffix(".tscn"))
		var dialog_name = Global.dialog_list_names.get(level_num, "default_boss")
		
		Global.dialog_story.emit(dialog_name, "level")
		queue_free()
