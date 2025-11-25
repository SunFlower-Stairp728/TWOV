extends Control

@onready var demo_label: Label = $demo
@onready var demo2_label: Label = $demo2
@onready var sound_demo = $sound_demo

@onready var animation_gui = get_node_or_null("/root/demo/animation_collision/gui_animation")

func _ready():
	# Настройка Label'ов
	demo_label.text = "КОНЕЦ"
	demo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	demo2_label.text = "ДЕМО"
	demo2_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	demo2_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	# Позиционирование Demo (КОНЕЦ) чуть выше центра
	demo_label.anchor_top = 0.4
	demo_label.anchor_bottom = 0.6
	demo_label.anchor_left = 0.0
	demo_label.anchor_right = 1.0
	
	# Позиционирование Demo2 (ДЕМО) под Demo
	demo2_label.anchor_top = 0.65
	demo2_label.anchor_bottom = 0.7
	demo2_label.anchor_left = 0.0
	demo2_label.anchor_right = 1.0
	
	demo_label.visible = false
	demo2_label.visible = false
	
	await get_tree().create_timer(3.0).timeout
	demo_label.visible = true
	sound_demo.play()
	await get_tree().create_timer(3.0).timeout
	demo2_label.visible = true
	sound_demo.play()
	# Запускаем таймер для перехода в меню
	await get_tree().create_timer(5.0).timeout  # Ждем 3 секунды
	animation_gui.play("finish_scene")
	await animation_gui.animation_finished
	return_to_menu()

func return_to_menu():
	Global.pause = 1
	Global.type_level = "menu"
	get_tree().change_scene_to_file("res://Scenes/levels/menu.tscn")
