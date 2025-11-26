extends Node

signal dialog_story(story_name: String, recipient: String)
signal item(item_name: Dictionary)

signal use(item: Dictionary)
signal action(_action: String, pos_y: float)

signal _load(params: Dictionary)
signal effects(action: Dictionary, index: int)

signal apply_parametrs

signal game_over
signal _continue

var items_inv = []

var settings_game = {
	"display": {
		"size": Vector2(1020.0, 720.0),
		"point_position": Vector2(0.0, 0.0),
		"size_display": 2.0
	},
	"shaders": {
		"background_speed_1": 1.0,
		"screen_curve": 1.0,
		"color_bleed_intensity": 0.3
	},
	"gui": {
		"size_gui": 500.0,
		"left_mode": false,
		"joystick_mode": 1,
		"margin_gui.x": 0,
		"margin_gui.y": 0
	}
}

const settings_path = "user://game_settings.cfg"

var index = -1

var bullet_modulate
var type_menu = "menu"
var type_debug
var type_device
var level = 1
var animation = 0
var gui_window = 0
var chapter_window = 0
var gui_size = 2
var gui_section = 2
var path_to_save_file = "user://The_worlds_of_void_game.cfg"
var section_game = "level"
var type_load = 0
var type_fight = "world"
var active_logo = 1
var pause = 0
var type_level = 0
var dialog_type = 0
var invicible = 0


@onready var boss_list_name = {
	1:"frog",
	7:"frog",
	8:"stasik",
	9:"spider",
	12:"frog",
	14:"stasik2",
	15:"stasik2",
	17:"stasik2",
	22:"stasik2",
	47:"frog",
}

@onready var chapter_list_names = {
	"chapter_1": 2,
	"chapter_2": 6,
	"chapter_3": 45
}

@onready var dialog_list_names = {
	0: "monolog_player",
	1: "learning",
	2: "intro",
	3: "monolog1",
	6: "monolog3",
	7: "castle",
	8: "dialog_stasa",
	10: "dialog_slime_1",
	12: "dialog_slime_2",
	14: "dialog_slime_and_mr_signal_1"
}

@onready var effect_list = {
	4:{"params": {"effects": ["block meat", "box cube"], "time": [0.2, 0.2], "scale": [1.35, 80.0]}},
	14:{"params": {"effects": ["block meat", "box cube"], "time": [0.2, 0.2], "scale": [1.35, 80.0]}}
}

var game_data = {
	"player": {
		"health_heart": 15,
		"health_human": 15,
		"jump_force": 1100,
		"energy": 15,
		"jump": "double",
		"defence": 0,
		"add_damage": 0,
		"score": 0
		}
	}

func _ready():
	var scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	
	var regex = RegEx.new()
	regex.compile("(\\d+)")
	var result = regex.search(scene_name)
	
	if result:
		level = result.get_string().to_int()
	
	type_debug = "debug" if OS.is_debug_build() else "release"
	
	match OS.get_name():
		"Windows", "OSX", "Linux": type_device = 1
		"Android", "iOS": type_device = 2
		_: type_device = 2
	
	
	var current_scene_name = get_tree().current_scene.scene_file_path.get_file().to_lower()
	
	if current_scene_name.begins_with("menu"):
		type_level = "menu"
		pause = 1
	elif current_scene_name.begins_with("level"):
		type_level = "level_2"
		pause = 0
	elif current_scene_name.begins_with("song"):
		type_level = "song"
		pause = 0
	
	# Load game settings
	load_game_settings()
	

func load_game():
	var config_game = ConfigFile.new()
	if type_load == 0:
		config_game.load(path_to_save_file)
		Global.level = config_game.get_value(section_game, "level_number", 1)
		type_load = 1

func save_game():
	var config_game = ConfigFile.new()
	config_game.set_value(section_game, "level_number", Global.level)
	config_game.save(path_to_save_file)

func save_game_settings():
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	if file:
		file.store_var(settings_game)
		
		return true
	return false

func load_game_settings():
	if FileAccess.file_exists(settings_path):
		var file = FileAccess.open(settings_path, FileAccess.READ)
		var loaded = file.get_var()
		if loaded is Dictionary:
			for category in settings_game:
				if loaded.has(category) and loaded[category] is Dictionary:
					for key_load in settings_game[category]:
						if loaded[category].has(key_load):
							settings_game[category][key_load] = loaded[category][key_load]
	
