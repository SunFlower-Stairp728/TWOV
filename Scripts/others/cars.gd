extends Node2D

@export var textures: Array[Texture2D] = [
	preload("res://Sprite/decorations/cars/car_1.png"),
	preload("res://Sprite/decorations/cars/car_2.png"),
	preload("res://Sprite/decorations/cars/car_3.png"),
	preload("res://Sprite/decorations/cars/car_4.png")
]

@onready var car_sprite = $cars

var new_texture_index = 0
var last_texture_index := -1

func _ready():
	if randf() < 0.6:
		car_sprite.flip_h = true
	
	if Global.level == 1:
		new_texture_index = 3
	elif Global.level == 2:
		_set_random_texture()
	car_sprite.texture = textures[new_texture_index]

func _set_random_texture():
	if textures.is_empty():
		return
	
	new_texture_index = last_texture_index
	
	if textures.size() > 1:
		while new_texture_index == last_texture_index:
			new_texture_index = randi() % textures.size()
	else:
		new_texture_index = 0
	
	last_texture_index = new_texture_index
	car_sprite.texture = textures[new_texture_index]
