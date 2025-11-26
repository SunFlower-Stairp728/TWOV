extends CPUParticles2D


@onready var camera = get_viewport().get_camera_2d()

func _ready():
	await get_tree().process_frame
	emission_rect_extents = Vector2(Global.settings_game["display"]["size"].x + (Global.settings_game["display"]["size"].x / 4), 1.0)
	

func _process(_delta: float):
	var fps = Engine.get_frames_per_second()
	fixed_fps = int(fps / 1.3)
	
	self.global_position = Vector2(camera.global_position.x, (camera.global_position.y - Global.settings_game["display"]["size"].y) - (Global.settings_game["display"]["size"].y / 4))
	
