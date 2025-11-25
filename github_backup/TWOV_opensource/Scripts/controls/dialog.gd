extends Control

@onready var music_bg = get_parent().get_node("music_bg")
@onready var sound = get_parent().get_node("sound")


@onready var main_scene = get_node("/root/level_2") if Global.type_level == "level_2" else get_node_or_null("/root/menu/CanvasLayer/menu/main_settings/Window/level_2") if Global.type_level == "menu" else null
@onready var gui_control = main_scene.get_node("gui_control")


@onready var visual_scene = $visual_scene
@onready var visual_dialog = $dialog_bar/visual_dialog

@onready var dialogue_panel = get_parent()


@onready var dialog_text = $dialog_bar/text


var dialogs

var auto_process = false
var animation_text = true
var block_input = false

var current_dialog_index = 0
var current_story = ""

func _ready():
	Global.dialog_story.connect(show_dialog_story)
	
	dialogue_panel.visible = false
	visual_scene.visible = false
	load_dialogs()

func load_dialogs():
	var path_dialogs = load("res://Scripts/others/language/%s_dialog.gd" % OS.get_locale_language())
	var instance_dialog = path_dialogs.new()
	dialogs = instance_dialog.dialog_stories


func _on_play_sound(sound_name: String):
	var sound_path = "res://sounds/level sounds/effects/%s.mp3" % sound_name
	var sound_load = load(sound_path)
	if sound_load:
		sound.stream = sound_load
		sound.play()


func _input(event):
	if event.is_action_pressed("ui_accept") and block_input == false:
		animation_text = true
		current_dialog_index += 1
		process_next_dialog()
		dialog_text.visible_ratio = 0.0
		create_tween().tween_property(dialog_text, "visible_ratio", 1.0, dialog_text.text.length() - (dialog_text.text.length() / 1.05) ).set_trans(Tween.TRANS_LINEAR)
	elif event.is_action_pressed("ui_cancel") and block_input == false:
		animation_text = false
		current_dialog_index += 1
		process_next_dialog()

func _on_change_music(music_name: String):
	if music_name != "null":
		var music_path = "res://sounds/level sounds/scenes sounds/%s.mp3" % music_name
		var music = load(music_path)
		music_bg.stream = music
		music_bg.play()
	else:
		music_bg.stream_paused = true

func show_dialog_story(story_name: String, recipient: String):
	if recipient == "level":
		if story_name in dialogs:
			main_scene.get_node("player/Camera2D/sky_layer/background_music").stream_paused = true
			gui_control.visible_control(true, "select_buttons")
			gui_control.visible_control(false, "player_control")
			
			Global.animation = 1
			Global.pause = 1
			await get_tree().create_timer(0.5).timeout
			dialogue_panel.visible = true
			
			current_story = story_name
			process_next_dialog()

func process_next_dialog():
	if dialogue_panel.visible == true:
		var current = dialogs[current_story][current_dialog_index]
		if current.has("action"):
			var params = current.get("params", {})
			handle_action(current["action"], params)
		elif current.has("text"):
			show_dialog_line(current["text"], current["icon"])
		

func handle_action(action: String, params: Dictionary = {}):
	match action:
		"line_type_next":
			if params.has("blocked"):
				if params["blocked"] == true:
					block_input = true
			if params.has("auto"):
				if params["auto"] == true and auto_process == false:
					block_input = true
					auto_process = true
					while true:
						if auto_process == false:
							break
						current_dialog_index += 1
						process_next_dialog()
						if animation_text == true:
							await get_tree().create_timer(0.5 + (dialog_text.text.length() - (dialog_text.text.length() / 1.05))).timeout
						else:
							await get_tree().create_timer(0.5).timeout
				if params["auto"] == false:
					auto_process = false
					block_input = false
		"play":
			if params.has("play_music"):
				_on_change_music(params["play_music"]["music"])
			if params.has("play_sound"):
				_on_play_sound(params["play_sound"]["sound"])
			current_dialog_index += 1
			current_dialog_index += 1
		"finish":
			current_dialog_index += 1
			end_dialog_sequence(params)
		"next_dialog":
			if animation_text == true:
				block_input = true
				await get_tree().create_timer(params["time"]).timeout
				block_input = false
			current_dialog_index += 1
			process_next_dialog()
		"fight":
			main_scene.fight(params)
			current_dialog_index += 1
			process_next_dialog()
		"object":
			if params.has("summon"):
				main_scene.summon(params)
			if params.has("action"):
				var node = main_scene.get_node(params["action"]["object"])
				node.update(params["action"])
			current_dialog_index += 1
			process_next_dialog()
			
		"SCENE":
			visual_scene.visible = true
			if params["scene_params"].has("bg_scene"):
				visual_scene.get_node("background").color = params["scene_params"]["bg_scene"]["color"]
			if params["scene_params"].has("photo"):
				visual_scene.get_node("photo/AnimationPlayer").play(params["scene_params"]["photo"]["animation_type"])
			if params["scene_params"].has("bg_text"):
				visual_dialog.visible = params["scene_params"]["bg_text"]["visible"]
			current_dialog_index += 1
			process_next_dialog()

func show_dialog_line(text, icon):
	if icon != "null":
		visual_dialog.get_node("icon_player_1").texture = load("res://Sprite/dialog/icons/%s.png" % icon)
		visual_dialog.get_node("icon_player_1").visible = true
	elif icon == "null":
		visual_dialog.get_node("icon_player_1").visible = false
	
	dialog_text.text = text

func end_dialog_sequence(params: Dictionary):
	music_bg.stop()
	if params.has("scene"):
		if params["scene"] == true:
			visual_scene.visible = false
	if params.has("dialog"):
		if params["dialog"] == true:
			main_scene.get_node("player/Camera2D/sky_layer/background_music").stream_paused = false
			gui_control.visible_control(false, "select_buttons")
			gui_control.visible_control(true, "player_control")
			
			Global.animation = 0
			Global.pause = 0
			
			block_input = false
			visual_dialog.visible = true
			dialogue_panel.visible = false
