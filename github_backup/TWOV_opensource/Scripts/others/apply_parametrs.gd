extends Node

var shader = self

func _ready():
	Global.apply_parametrs.connect(_apply_parametrs)
	
	_apply_parametrs()

func _apply_parametrs():
	shader.material.set_shader_parameter("color_bleed_intensity", Global.settings_game["shaders"]["color_bleed_intensity"])
	shader.material.set_shader_parameter("speed", Global.settings_game["shaders"]["background_speed_1"])
