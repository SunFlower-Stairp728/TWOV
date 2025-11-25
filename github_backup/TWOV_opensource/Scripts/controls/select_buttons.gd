extends Control

var current_index := 0
var buttons: Array
var scene

var modulate_button
var input_lock = false

@onready var main_menu = get_node("/root/menu/CanvasLayer/menu/main_menu") if Global.type_level == "menu" else null
@onready var main_chapters = get_node("/root/menu/CanvasLayer/menu/main_chapters") if Global.type_level == "menu" else null
@onready var main_settings = get_node("/root/menu/CanvasLayer/menu/main_settings") if Global.type_level == "menu" else null

@onready var control_gui = get_node_or_null("/root/level_2/gui_control") if Global.type_level == "level_2" else get_node_or_null("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/player/gui_control") if Global.type_level == "menu" else null


@onready var sound = get_node_or_null("/root/menu/CanvasLayer/menu/choose_button") if Global.type_level == "menu" else get_node_or_null("/root/level_2/gui_control/pause/choose_button") if Global.type_level == "level_2" else null
@onready var animation = get_node_or_null("/root/menu/CanvasLayer/menu/background/background_animation") if Global.type_level == "menu" else get_node_or_null("/root/level_2/gui_control/pause/visual/background/background_animation") if Global.type_level == "level_2" else get_node_or_null("/root/level_2/mini_game/player_heart/gui_control/pause/background/background_animation") if Global.type_fight == "fight" else null
@onready var animation_gui = get_node_or_null("/root/menu/animation_collision/gui_animation") if Global.type_level == "menu" else get_node_or_null("/root/level_2/gui_control/animation_collision/gui_animation") if Global.type_level == "level_2" else null


@onready var background_music = get_node_or_null("/root/level_2/player/Camera2D/sky_layer/background_music") if Global.type_level == "level_2" else get_node_or_null("/root/menu/background music")

@onready var background = get_node("/root/menu/CanvasLayer/menu/background") if Global.type_level == "menu" else null
@onready var pause_music = get_node_or_null("/root/level_2/gui_control/pause/pause_music") if Global.type_fight == "world" else get_node_or_null("/root/level_2/mini_game/player_heart/gui_control/pause/pause_music") if Global.type_fight == "fight" else null


func _ready():
	if Global.type_level == "menu":
		var system_time = Time.get_datetime_dict_from_system().hour
		if system_time >= 0 and system_time <= 3:
			background.texture = preload("res://Sprite/blocks/meat.png")
			background.material.set_shader_parameter("texture_scale", 1.0)
		elif system_time >= 4 and system_time <= 5:
			background.texture = preload("res://Sprite/blocks/arcade_6.png")
		elif system_time >= 6 and system_time <= 7:
			background.texture = preload("res://Sprite/blocks/arcade_7.png")
		elif system_time >= 8 and system_time <= 10:
			background.texture = preload("res://Sprite/blocks/arcade_3.png")
		elif system_time >= 11 and system_time <= 15:
			background.texture = preload("res://Sprite/blocks/arcade_4.png")
		elif system_time >= 16 and system_time <= 17:
			background.texture = preload("res://Sprite/blocks/arcade_5.png")
		elif system_time >= 18 and system_time <= 20:
			background.texture = preload("res://Sprite/blocks/arcade_2.png")
		elif system_time >= 21 and system_time <= 22:
			background.texture = preload("res://Sprite/blocks/arcade_1.png")
		elif system_time >= 23:
			background.texture = preload("res://Sprite/blocks/arcade_8.png")
	
	buttons = find_children("", "Button", true, false)
	
	highlight_button(0)
	

	for button in buttons:
		if button.is_connected("pressed", _on_button_pressed.bind(button)):
			button.disconnect("pressed", _on_button_pressed.bind(button))
		button.connect("pressed", _on_button_pressed.bind(button))

func _process(_delta):
	if Global.pause != 0:
		if buttons.size() > 0 and buttons[current_index].visible and !buttons[current_index].disabled and buttons[current_index].is_visible_in_tree():
			if Input.is_action_just_pressed("ui_up"):
				current_index = wrapi(current_index - 1, 0, buttons.size())
				highlight_button(current_index)
				sound.play()
			elif Input.is_action_just_pressed("ui_down"):
				current_index = wrapi(current_index + 1, 0, buttons.size())
				highlight_button(current_index)
				sound.play()
			elif Input.is_action_just_pressed("ui_accept"):
				button_press(buttons[current_index], "press")
				input_lock = true
				await get_tree().create_timer(0.05).timeout
				buttons[current_index].emit_signal("pressed")
				input_lock = false
			elif Input.is_action_just_pressed("ui_cancel"):
				if Global.type_level == "menu" and Global.type_menu != "menu" and Global.type_menu != "settings":
					get_node("/root/menu/CanvasLayer/menu/main_%s" % Global.type_menu).visible = false
					Global.type_menu = "menu"
					get_node("/root/menu/CanvasLayer/menu/main_%s" % Global.type_menu).visible = true
					

func highlight_button(index: int):
	for i in range(buttons.size()):
		buttons[i].modulate = Color.WHITE if i != index else Color(0.7, 0.7, 0.7)

func _on_button_pressed(button: Button):
	if button.is_visible_in_tree():
		match button.name:
			"play":
				if button.visible and !button.disabled and Global.pause == 1 and Global.type_level == "menu" and Global.type_menu == "menu":
					Global.load_game()
					Global.type_level = "level_2"
					Global.type_fight = "world"
					Global.pause = 0
					animation.play("start")
					await animation.animation_finished
					animation_gui.play("finish_scene")
					await animation_gui.animation_finished
					Global.animation = 0
					scene = load("res://Scenes/levels/worlds/level_%d.tscn" % Global.level)
					call_deferred("change_scene")
				
			"settings":
				if Global.type_menu == "menu":
					Global.type_menu = "settings"
					
					var path = {
						"type": "setting",
						"name_fight": "null",
						"animation": false,
						"screen_size": get_viewport().get_visible_rect().size
					}
					
					main_settings.get_node("Window").window(path)
					main_settings.visible = true
				
			"exit":
				if button.visible and !button.disabled and Global.pause == 1 and Global.type_level == "menu":
					if Global.type_menu == "menu":
						Global.save_game()
						get_tree().quit()
					
			"chapters":
				if button.visible and !button.disabled and Global.pause == 1 and Global.type_level == "menu":
					if Global.type_menu == "menu":
						main_menu.visible = false
						main_chapters.visible = true
						await get_tree().process_frame
						Global.type_menu = "chapters"
			
			"exit_menu":
				if button.visible and !button.disabled and Global.pause == 1:
					if Global.type_level == "level_2":
						Global.type_level = "menu"
						Global.type_menu = "menu"
						Global.pause = 1
						Global.active_logo = 1
						animation.play("start")
						await animation.animation_finished
						animation_gui.play("finish_scene")
						await animation_gui.animation_finished
						scene = load("res://Scenes/levels/menu.tscn")
						call_deferred("change_scene")
				
			"resume":
				if button.visible and !button.disabled and Global.pause == 1:
					pause_music.stop()
					Global.pause = 0
					Global.animation = 0
					background_music.stream_paused = false
					control_gui.visible_control(true, "player_control")
					control_gui.visible_control(false, "select_buttons")
						
					control_gui.pause.visible = false
				
			"attack":
				if button.visible and !button.disabled and Global.pause == 1 and Global.type_fight == "fight":
					var main_fight = get_node_or_null("/root/level_2/mini_game") if Global.type_level == "level_2" else get_node_or_null("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/mini_game") if Global.type_level == "menu" else null
					main_fight.attack()
				
			"items":
				if button.visible and !button.disabled and Global.pause == 1 and Global.type_fight == "fight":
					control_gui._items_start()
					
			"defense":
				if button.visible and !button.disabled and Global.pause == 1 and Global.type_fight == "fight":
					var main_fight = get_node_or_null("/root/level_2/mini_game") if Global.type_level == "level_2" else get_node_or_null("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/mini_game") if Global.type_level == "menu" else null
					main_fight.start_enemy_attack()
					Global.player_list[0]["defense"] += randi_range(1,2)
					
		if button.name.begins_with("slot_inventory_"):
			if button.visible and !button.disabled and Global.pause == 1:
				var slot_num = int(button.name.trim_prefix("slot_inventory_"))
				
				if slot_num < Global.items_inv.size() and Global.items_inv[slot_num] is Dictionary:
					var item = Global.items_inv[slot_num]
					
					
					if item.has("name") and item["name"] != "пусто":
						if item.get("use", false) == false:
							if item["name"] != "меч":
								item["use"] = true
								button.text = "пусто"
								Global.item.emit(item)
								Global.items_inv[slot_num] = {"name": "пусто", "use": true}
							Global.use.emit(item)
							control_gui._items_end()
					else:
						print("Слот пустой")
				else:
					print("Нет предмета в этом слоте")
				
		elif button.name.begins_with("chapter_"):
			if button.visible and !button.disabled and Global.pause == 1 and Global.type_menu == "chapters":
				var chapter_num = Global.chapter_list_names.get(button.name, "chapter_1")
				if Global.level >= chapter_num:
					scene = load("res://Scenes/levels/level_%d.tscn" % chapter_num)
					Global.level = chapter_num
					Global.type_level = "level_2"
					Global.type_fight = "world"
					Global.pause = 0
					animation.play("start")
					await animation.animation_finished
					animation_gui.play("finish_scene")
					await animation_gui.animation_finished
					Global.animation = 0
					scene = load("res://Scenes/levels/level_%d.tscn" % Global.level)
					call_deferred("change_scene")
				else:
					button_press(button, "block")

func button_press(button: Button, action: String):
	modulate_button = button.modulate
	if action == "block":
		button.modulate = Color.RED
	elif action == "press":
		button.modulate = Color.YELLOW
	await get_tree().create_timer(0.05).timeout
	button.modulate = modulate_button

func change_scene():
	get_tree().change_scene_to_packed(scene)
