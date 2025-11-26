extends Sprite2D

@onready var player = get_node("/root/level_2/player")
@onready var eyes_animation = $AnimationPlayer
@export var textures: Array[Texture2D] = [
	preload("res://Sprite/decorations/eyes/eyes_1.png"),
	preload("res://Sprite/decorations/eyes/eyes_2.png"),
	preload("res://Sprite/decorations/eyes/eyes_3.png")
]


var texture_index = 0

func _ready():
	eyes_animation.play("shake")
	_set_random_texture()

func _process(_delta):
	var distance = global_position.distance_to(player.global_position)
	
	if distance < 50:
		eyes_animation.speed_scale = 20.0
	elif distance < 100:
		eyes_animation.speed_scale = 10.0
	elif distance < 200:
		eyes_animation.speed_scale = 5.0
	else:
		eyes_animation.speed_scale = 1.0  # Базовая скорость

func _set_random_texture():
	var rand_value = randf()
	
	if rand_value < 0.05:
		texture_index = 2
	elif rand_value < 0.8:
		texture_index = 1
	else:
		texture_index = 0
	
	self.texture = textures[texture_index]
