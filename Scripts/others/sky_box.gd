extends CanvasLayer

@onready var music = $background_music
@onready var sky_box = $sky_box
@onready var main_level = get_node("/root/level_2") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2") if Global.type_level == "menu" else null

var size_screen

var shader

func _ready():
	Global.effects.connect(_effect)
	get_viewport().size_changed.connect(_update_bg)
	if main_level.play_music == true:
		music.stream = load("res://sounds/musics/" + str(main_level.type) + "/music_%s.mp3" % randi_range(main_level.min_index_music, main_level.max_index_music))
		music.stream.loop = true
		music.play()
	_update_bg()


func _update_bg():
	size_screen = get_viewport().get_visible_rect().size
	
	sky_box.texture = main_level.sky_texture
	if main_level.inf_sky == true:
		sky_box.stretch_mode = TextureRect.STRETCH_TILE
		shader = preload("res://shaders/infinite_background.gdshader")
		sky_box.material.shader = shader
		
		sky_box.material.set_shader_parameter("texture_scale", 0.02)
		sky_box.material.set_shader_parameter("vertical_scroll_speed", 1.0)
		sky_box.material.set_shader_parameter("color_brightness", main_level.brightness_power)
	elif main_level.inf_sky == false:
		sky_box.material.shader = null
		
	
	for i in range(4):
		if i != 0:
			var backgrounds_objs = get_node_or_null("background_%s" % i)
			var backgrounds_objs_clouds = get_node_or_null("background_cloud_%s" % i)
			if backgrounds_objs:
				backgrounds_objs.motion_mirroring = Vector2(size_screen.x, 0.0)
			if backgrounds_objs_clouds:
				backgrounds_objs_clouds.motion_mirroring = Vector2(size_screen.x, 0.0)
			
			var background_obj = get_node_or_null("background_" + str(i) + "/background_obj_" + str(i))
			if background_obj:
				var path_bg = "background_%s_texture" % i
				background_obj.texture = main_level.get(path_bg)
				
				background_obj.size = size_screen
				background_obj.position = Vector2(0.0, size_screen.y / (1.5 + (i / 10.0)))
				
				background_obj.material.set_shader_parameter("brightness", (main_level.brightness_power - i / 10.0) + 0.2)
			
			var background_obj_clouds = get_node_or_null("background_cloud_" + str(i) + "/background_obj_" + str(i))
			if main_level.clouds == true:
				if background_obj_clouds:
					var path_cloud = "cloud_%s_texture" % i
					background_obj_clouds.texture = main_level.get(path_cloud)
					background_obj_clouds.size = Vector2(size_screen.x * 2, size_screen.y)
					background_obj_clouds.position = Vector2(0.0, background_obj.position.y - size_screen.y)
					background_obj_clouds.get_parent().motion_mirroring = Vector2(size_screen.x * 2, 0.0)
			else:
				if background_obj_clouds:
					backgrounds_objs_clouds.queue_free()
			
			

func _effect(params: Dictionary, index: int):
	music.stream_paused = true
	sky_box.stretch_mode = TextureRect.STRETCH_TILE
	sky_box.texture = load("res://Sprite/blocks/%s.png" % params["params"]["effects"][index])
	sky_box.scale = Vector2(params["params"]["scale"][index], params["params"]["scale"][index])
	await get_tree().create_timer(params["params"]["time"][index]).timeout
	music.stream_paused = false
	_update_bg()
