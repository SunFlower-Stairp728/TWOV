extends CanvasLayer

var type_enter = true

@onready var menu_group = $/root/menu/CanvasLayer/menu
@onready var background_music_menu = $"/root/menu/background_music"

@onready var animation_gui = get_node_or_null("/root/menu/animation_collision/gui_animation")

@onready var scene = get_node_or_null("/root/menu/animation_scene")

@onready var discl = $/root/menu/discl
@onready var text_discl = $press
@onready var background_music_press = $"baclground music press"
@onready var background = $background
@onready var play = $PLAY

@onready var button_press = $button_press

func _ready():
	Global._continue.connect(self._continue)
	discl.visible = false
	background.color = Color(0, 0, 0)
	text_discl.visible = false
	play.visible = false
	
	
	if Global.active_logo == 0:
		discl.visible = true
		if Global.type_device == 1:
			text_discl.text = "Нажмите Enter чтобы продолжить"
		elif Global.type_device == 2:
			text_discl.text = "Нажмите A чтобы продолжить"
	elif Global.active_logo == 1:
		animation_gui.play("start_scene")
		Global.dialog_type = 0
		menu_group.visible = true
		background_music_menu.play()
		type_enter = false
	

func _continue():
	play.visible = true
	background.color = Color(0, 0, 1)
	background_music_press.play()
	Global.dialog_type = 0
	while type_enter == true:
		text_discl.visible = false
		await get_tree().create_timer(1.0).timeout
		text_discl.visible = true
		button_press.play()
		await get_tree().create_timer(1.0).timeout

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if self.visible and Global.pause == 1 and Global.dialog_type == 0:
			animation_gui.play("finish_scene")
			type_enter = false
			Global.pause = 0
			await animation_gui.animation_finished
			discl.hide()
			scene.visible = false
			await get_tree().create_timer(5.0).timeout
			Global.pause = 1
			background_music_press.stop()
			animation_gui.play("start_scene")
			background_music_menu.play()
			menu_group.show()
			Global.active_logo = 1
