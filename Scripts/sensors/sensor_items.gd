extends Node2D

@onready var items_list = {
	1:{"name": "меч", "damage": 2, "use": false},
	2:{"name": "зелье", "health": 5, "use": false}
}

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		var current_scene_name = get_tree().current_scene.scene_file_path.get_file().to_lower()
		# Извлекаем номер уровня (убираем "level_", оставляем цифру)
		var level_num = int(current_scene_name.trim_prefix("level_").trim_suffix(".tscn"))
		var item_data = items_list.get(level_num, {"name": "пусто"})
		Global.item.emit(item_data)
		queue_free()
