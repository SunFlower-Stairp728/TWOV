extends CharacterBody2D

var SPEED = 300.0
var time = 0.0
const DIRECTION_SWAP_TIME = 2.0
var platform_direction = -1

@onready var parent = get_parent()

func _ready() -> void:
	if parent.name == "platform stone-":
		SPEED = -300.0
	elif parent.name == "platform stone+":
		SPEED = 300.0

func _physics_process(delta: float) -> void:
	if Global.pause == 0:
		time += delta
		if time >= DIRECTION_SWAP_TIME:
			time = 0
			platform_direction *= -1
	
	velocity.y = platform_direction * SPEED
	move_and_slide()
