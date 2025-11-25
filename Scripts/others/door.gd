extends Node2D


@onready var gui_animation = get_node("/root/level_2/gui_control/animation_collision/gui_animation") if Global.type_level != "menu" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/gui_control/animation_collision/gui_animation") if Global.type_level == "menu" else null
@onready var animation = get_node("AnimationPlayer")

@export var enter = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and enter == true:
		animation.play("close")
		Global.pause = 1
		await animation.animation_finished
		body.process_mode = Node.PROCESS_MODE_DISABLED
		body.visible = false
		await get_tree().create_timer(2.0).timeout
		gui_animation.play("finish_scene")
		await gui_animation.animation_finished
		Global.level += 1
		Global.save_game()
		var scene = load("res://Scenes/levels/worlds/level_%s.tscn" % Global.level)
		get_tree().change_scene_to_packed(scene)
