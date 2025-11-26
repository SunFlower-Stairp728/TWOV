extends CanvasLayer

@onready var screen_size = get_viewport().get_visible_rect().size

var tween: Tween

@onready var dead_player = $dead_sound
@onready var game_over_text_sound = $Game_over/game_over
@onready var game_over_sound = $Game_over/AudioStreamPlayer
@onready var animation_bg_game_over = $Game_over/animation_bg
@onready var game_over = $Game_over/background_game_over
@onready var game_label = $Game_over/game
@onready var over_label = $Game_over/over

@onready var box_animations = $Control_heart/box_tools/ColorRect/Animation
@onready var box = $Control_heart/box_tools


#кнопки управления персонажем
@onready var left: Button = $player_control/Control_player/left
@onready var right: Button = $player_control/Control_player/right
@onready var jump: Button = $player_control/Control_player/jump
@onready var dash: Button = $player_control/Control_player/dash
@onready var zoom: Button = $player_control/Control_player/zoom
@onready var exit_button: Button = $player_control/Control_player/exit
@onready var down: Button = $player_control/Control_player/sit_down 
@onready var pick_up: Button = $player_control/Control_player/pick_up

@onready var bar = $bar

@onready var health_number: Label = $bar/health/health_number
@onready var energy_number: Label = $bar/energy/energy_number

@onready var inventory = $inventory

@onready var energy: TextureRect = $bar/energy
@onready var animation = $animation_collision/gui_animation

@onready var pause = $pause
@onready var title = $pause/visual/title
@onready var exit = $pause/visual/exit_menu
@onready var resume = $pause/visual/resume

@onready var health = $bar/health
@onready var background_music = get_node("/root/level_2/player/Camera2D/sky_layer/background_music") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/player/Camera2D/sky_layer/background_music") if Global.type_level == "menu" else null 

@onready var pause_music = $pause/pause_music

var scene


var fps_samples = []
const FPS_SAMPLE_COUNT = 50

func _ready():
	inventory.visible = false
	animation_bg_game_over.visible = false
	game_over.visible = false
	game_label.visible = false
	over_label.visible = false
	box.visible = false
	animation.play("start_scene")
	
	Global.game_over.connect(_game_over)
	Global.action.connect(_action)
	
	pause.visible = false
	
	visible_control(false, "Virtual Joystick")
	visible_control(false, "select_buttons")
	visible_control(true, "player_control")
	
	setup_ui()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func select_act():
	visible_control(true, "select_buttons")
	_items_end()
	Global.pause = 1

func _items_start():
	box_animations.play("finish")
	await box_animations.animation_finished
	inventory.visible = true
	box.visible = false

func _items_end():
	inventory.visible = false
	box.visible = true
	box_animations.play("start")


func _on_viewport_size_changed():
	if is_inside_tree():
		setup_ui()

func setup_ui():
	if !is_inside_tree():
		return
	setup_pause_elements()

func setup_pause_elements():
	if !is_inside_tree():
		return
	var screen_size_menu = get_viewport().get_visible_rect().size
	var margin = 30
	title.position = Vector2(margin, margin)
	exit.position = Vector2(margin, screen_size_menu.y - exit.size.y - margin)
	resume.position = Vector2(margin, exit.position.y - resume.size.y - 10)

func _input(event):
	if event.is_action_pressed("ui_accept") and (Global.game_data["player"]["health_human"] <= 0 or Global.game_data["player"]["health_heart"] <= 0):
		Global.pause = 1
		Global.type_level = "menu"
		Global.type_fight = "world"
		animation.play("finish_scene")
		await animation.animation_finished
		await get_tree().create_timer(1.5).timeout
		scene = load("res://Scenes/levels/menu.tscn")
		call_deferred("change_scene")
	elif event.is_action_pressed("ui_exit"):
		_pause()

func change_scene():
	get_tree().change_scene_to_packed(scene)

func _action(action: String):
	if action == "energy":
		energy_number.text = str(Global.game_data["player"]["energy"])
	
	if action == "health":
		Global.game_data["player"]["heart"] = min(Global.game_data["player"]["health_heart"], 15)
		if Global.type_fight == "world":
			health_number.text = str(int(Global.game_data["player"]["health_human"]))
		elif Global.type_fight == "fight":
			health_number.text = str(int(Global.game_data["player"]["health_heart"]))

func _animation():
	animation.play("energy")


func _pause():
	if Global.type_fight == "world":
		background_music.stream_paused = true
	pause_music.play()
	box.visible = false
	Global.pause = 1
	Global.animation = 1
	visible_control(true, "select_buttons")
	visible_control(false, "player_control")
	pause.visible = true


func _game_over():
	if Global.type_fight == "world" or Global.type_fight == "fight":
		Global.animation = 1
		Global.pause = 1
		Global.type_fight = "world"
		Global.type_level = "level_2"
		
		dead_player.play()
		background_music.stop()
		visible_control(true, "select_buttons")
		visible_control(false, "player_control")
		animation_bg_game_over.visible = true
		await get_tree().create_timer(3.0).timeout
		game_over.visible = true
		await get_tree().create_timer(1.0).timeout
		game_over_sound.play()
		
		await get_tree().create_timer(1.0).timeout
		while Global.game_data["player"]["health_human"] <= 0 or Global.game_data["player"]["health_heart"] <= 0:
			game_label.visible = false
			over_label.visible = false
			await get_tree().create_timer(1.0).timeout
			game_over_text_sound.play()
			game_label.visible = true
			over_label.visible = true
			await get_tree().create_timer(1.0).timeout

func visible_control(action: bool, node: String):
	var node_gui = get_node(node)
	if Input.get_connected_joypads().size() <= 0:
		if Global.type_device == 2:
			node_gui.visible = action
	
