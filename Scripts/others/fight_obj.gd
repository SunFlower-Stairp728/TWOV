extends Sprite2D

var direction := Vector2.ZERO
var speed = 0.0
var _scale_factor = 1.0

@export var is_homing: bool = false
@export var homing_target: CharacterBody2D = null
@export var homing_power: float = 0.1

@onready var REFERENCE_RESOLUTION = Vector2(1020, 720)

func _ready():
	
	if is_homing == true:
		homing_target = get_node("/root/level_2/Window/level_fight/player_heart") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/Window/level_fight/player_heart") if Global.type_level == "menu" else null
	
	rotation = direction.angle()
	flip_v = abs(direction.angle()) > PI/2
	
	var viewport_size = get_viewport().get_visible_rect().size
	_scale_factor = viewport_size.x / REFERENCE_RESOLUTION.x
	

func _physics_process(delta: float) -> void:
	if is_homing and homing_target and is_instance_valid(homing_target):
		var target_direction = (homing_target.global_position - global_position).normalized()
		direction = direction.lerp(target_direction, homing_power * delta)
	
	rotation = direction.angle()
	flip_v = abs(direction.angle()) > PI/2
	
	position += direction * speed * _scale_factor * delta

func change_texture(texture_obj: String):
	texture = load("res://Sprite/decorations/fight/%s.png" % texture_obj)
