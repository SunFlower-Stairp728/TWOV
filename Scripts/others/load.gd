extends CanvasLayer

@onready var menu_group = $/root/menu/CanvasLayer/menu
@onready var animation_go = get_node("/root/menu/animation_collision/gui_animation")
@onready var animation_intro = get_node("/root/menu/load/Control/AnimationPlayer")
@onready var load_group = $/root/menu/load


func _ready():
	if Global.active_logo == 1:
		load_group.visible = false
	elif Global.active_logo == 0:
		animation_go.play("start_scene")
		load_group.visible = true
		menu_group.hide()
		animation_intro.play("intro")
		await animation_intro.animation_finished
		animation_go.play("finish_scene")
		await animation_go.animation_finished
		animation_go.play("start_scene")
		load_group.hide()
		Global.show_dialog_story.emit("intro")
