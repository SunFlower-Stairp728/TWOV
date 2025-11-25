extends Node2D

var main_scene = self
@onready var window_level = preload("res://Scenes/levels/level_fight.tscn").instantiate()

@onready var background_music = get_node("player/Camera2D/sky_layer/background_music") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/player/Camera2D/sky_layer/background_music") if Global.type_level == "menu" else null 
@onready var background_music_fight = get_node_or_null("level_2/mini_game/fight") if Global.type_fight == "fight" else null
@onready var gui = get_node("gui_control")
@onready var player = get_node("player")

@onready var particles_scenes = {
	0: null,
	1: preload("res://Scenes/effects/rain.tscn").instantiate()
}




@export_group("background_music")
@export var play_music = true
@export var type = "world"

@export_range(1, int(INF)) var min_index_music = 1
@export_range(1, int(INF)) var max_index_music = 1


@export_group("world_visual")
@export var light = Color(1.0, 1.0, 1.0)

enum particles {none, rain}
@export var type_particles = particles.none

@export_subgroup("sky")
@export var sky_texture : Texture2D = preload("res://Sprite/decorations/sky/sky_box_2d_happy.png")
@export var inf_sky = false
@export var clouds : bool = true

@export_subgroup("background")
@export var background_1_texture: Texture2D = preload("res://Sprite/decorations/sky/backgrounds/background_sky_happy_1.png")
@export var background_2_texture: Texture2D = preload("res://Sprite/decorations/sky/backgrounds/background_sky_happy_2.png")
@export var background_3_texture: Texture2D = preload("res://Sprite/decorations/sky/backgrounds/background_sky_happy_3.png")
@export_range(0.0, 1.0) var brightness_power = 0.9

@export_subgroup("cloud")
@export var cloud_1_texture: Texture2D = preload("res://Sprite/decorations/sky/backgrounds/background_sky_happy_layer_1.png")
@export var cloud_2_texture: Texture2D = preload("res://Sprite/decorations/sky/backgrounds/background_sky_happy_layer_2.png")
@export var cloud_3_texture: Texture2D = null

@export_subgroup("environment")
enum type_environment {normal, saturation, arcade}
@export var environment = type_environment.normal

func _ready():
	Global.animation = 0
	Global.pause = 0
	$layer_light.color = light
	if type_particles != particles.none:
		main_scene.add_child(particles_scenes[type_particles])
	

func summon(params: Dictionary = {}):
	var path = "res://Scenes/entities/" + params["summon"]["object"] + ".tscn"
	
	var _load_state = ResourceLoader.load_threaded_request(path)
	
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	
	var scene_obj = ResourceLoader.load_threaded_get(path)
	var object = scene_obj.instantiate()
	main_scene.add_child(object)
	
	var screen_size = get_viewport_rect().size
	
	if params["summon"]["appearance"] == "on_player":
		object.global_position = Vector2(player.global_position.x - params["summon"]["pixel"].x, player.global_position.y - screen_size.y - 300.0)
		
		create_tween().tween_property(object, "global_position", Vector2(object.global_position.x, player.global_position.y - params["summon"]["pixel"].y), 1.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		create_tween().tween_property(object,"global_rotation_degrees", 360.0, 1.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	elif params["summon"]["appearance"] == "slime_start":
		object.global_position = Vector2(player.global_position.x - params["summon"]["pixel"].x, player.global_position.y - params["summon"]["pixel"].y)
		object.update({"object": "slime_clone_player", "animation": {"type": "unslime"}})


func fight(params: Dictionary = {}):
	background_music.stream_paused = true
	
	Global.animation = 2
	Global.type_fight = "fight"
	Global.pause = 1
	
	gui.animation.play("finish_scene")
	await gui.animation.animation_finished
	gui.animation.play("start_scene")
	main_scene.add_child(window_level)
	
	Global._load.emit(params["name_fight"])
	main_scene.process_mode = Node.PROCESS_MODE_DISABLED
	

func win():
	main_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	Global.animation = 1
	Global.type_fight = "world"
	
	await get_tree().create_timer(3.0).timeout
	gui.visible_control(true, "player_control")
	window_level.queue_free()
	
	Global.animation = 0
	Global.pause = 0
	
	gui.animation.play("start_scene")
	await gui.animation.animation_finished
	background_music.stream_paused = false
