extends Node2D

var sprite = self
var material_obj = ShaderMaterial.new()

@onready var main_level = get_node("/root/level_2") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2") if Global.type_level == "menu" else null

func _ready():
	if main_level.environment == main_level.type_environment.saturation:
		apply_2d_shader("saturation")
	if main_level.environment == main_level.type_environment.arcade:
		apply_2d_shader("mask_texture")
		sprite.material.set_shader_parameter("mask_texture", preload("res://Sprite/blocks/arcade_15.png"))
		sprite.material.set_shader_parameter("intensity", 0.0)


func apply_2d_shader(shader_name: String):
	var shader = load("res://shaders/%s.gdshader" % shader_name)
	material_obj.shader = shader
	
	if sprite:
		sprite.material = material_obj
