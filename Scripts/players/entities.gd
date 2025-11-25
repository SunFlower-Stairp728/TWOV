extends CharacterBody2D

@export var ai : bool = false
@onready var player = get_node("/root/level_2/player")

var jump_force = 1000.0

var idle = false

var direction = 1
var speed = randi_range(100, 200)

@onready var animation = $Node2D/AnimationPlayer
@onready var check_wall = $Node2D/check_wall
@onready var bot = $Node2D

func _ready():
	collision_layer = 0
	animation.play("idle")
	if ai == true:
		direction = [-1, 1][randi() % 2]


func _physics_process(_delta):
	if not is_on_floor():
		velocity += get_gravity() * 0.05
	else:
		if velocity.x != 0 and velocity.y == 0:
			velocity.x = 0.0
	
	if ai == true:
		if idle == false:
			bot.scale.x = direction
			velocity.x = direction * speed
			animation.play("walk")
			if check_wall.is_colliding():
				action("change", null)
		
	move_and_slide()

func update(params: Dictionary = {}):
	if params.has("animation"):
		animation.play(params["animation"])
	
	if params.has("direction"):
		if params["direction"] == "right":
			bot.scale.x = 1.0
		elif params["direction"] == "left":
			bot.scale.x = -1.0
	if params.has("action_object"):
		var params_action = params.get("action_object", {})
		velocity = params_action["jump"]

func action(_action: String, amount):
	if _action == "change":
		idle = true
		animation.play("idle")
		velocity.x = 0.0
		direction *= -1
		bot.scale.x = direction
		await get_tree().create_timer(randf_range(0.5, 2.5)).timeout
		idle = false
	elif _action == "stop":
		idle = true
		animation.play("idle")
		velocity.x = 0.0
		await get_tree().create_timer(randf_range(2.5, 8.5)).timeout
		idle = false
	elif _action == "happy":
		if is_on_floor():
			velocity.y = randf_range(-1000.0, -800.0)
			animation.play("jump")
		await get_tree().create_timer(randf_range(2.5, 8.5)).timeout
		idle = false
	elif _action == "repulsive":
		if global_position.y > amount:
			velocity.y = jump_force * 1.6
		else:
			velocity.y = -jump_force * 1.6
