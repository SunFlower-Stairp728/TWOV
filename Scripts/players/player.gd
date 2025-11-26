extends CharacterBody2D

@onready var check_celling = $player_sprites/raycasts/check_celling
@onready var check_take = $player_sprites/raycasts/check_take
@onready var check_wall = $player_sprites/raycasts/check_wall

var direction = 0

var animation_lock = false
@onready var animations_player = $player_sprites/AnimationPlayer
@onready var player_collision = $CollisionShape2D
@onready var player = $player_sprites
@onready var REFERENCE_RESOLUTION = get_viewport().get_visible_rect().size

var player_damage_timer = 1.0

var push = false
var sit_down = false

var speed_dash = 1500.0
var speed = 400.0

var jump_count = 1
var max_jumps = 2

var gravity = 0.05
var death_fall_max = 20000.0

var pick = false
var take_cooldown = false
var take_cooldown_timer = 0.3
var picked_body = null
var offset_take_body_x = 100.0
var offset_take_body_y = -30.0

var block = false
var can_dash = true

var dash_timer = 0.0
var dash_end = 0.2
var dash_cooldown = 0.0
var dash_end_cooldown = 0.35

func _ready():
	Global.game_data["player"]["health_human"] = 15
	Global.game_data["player"]["health_heart"] = 15
	Global.game_data["player"]["energy"] = 15
	
	

func _physics_process(delta):
	if not is_on_floor() or is_on_ceiling() or gravity < 0:
		velocity += get_gravity() * gravity
		if velocity.y > death_fall_max and gravity > 0 or velocity.y < -death_fall_max and gravity < 0:
			if Global.game_data["player"]["human"] > 0:
				action({"damage": {"amount": Global.game_data["player"]["human"]}}, "action")
		
	if is_on_floor() or is_on_ceiling():
		jump_count = 1
		
	direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		if block == false:
			if animation_lock == false:
				if sit_down == false:
					animations_player.play("walk")
				else:
					animations_player.play("climb_walk")
			if push == false:
				velocity.x = direction * speed
			player.scale.x = direction
			
			if check_wall.get_collider() != null:
				if push == false:
					if animation_lock == false:
						animation_lock = true
						push = true
						animations_player.play("push")
					velocity.x = 0
			else:
				if push == true:
					push = false
					animation_lock = false
	if (direction == 0 or Global.pause != 0) and (Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right")):
		if animation_lock == false:
			if sit_down == false:
				animations_player.play("idle")
			else:
				animations_player.play("climb_idle")
		velocity.x = 0
	
	if Input.is_action_just_pressed("ui_jump") and not check_celling.is_colliding():
		if jump_count < max_jumps:
			if Global.game_data["player"]["energy"] != 0:
				jump_count += 1
				if gravity < 0:
					velocity.y = Global.game_data["player"]["jump_force"]
				else:
					velocity.y = -Global.game_data["player"]["jump_force"]
				
				Global.game_data["player"]["energy"] -= 1
				Global.action.emit("energy")
			else:
				if is_on_floor() or is_on_ceiling():
					velocity.y = -Global.game_data["player"]["jump_force"]
		
		if animation_lock == false:
			animation_lock = true
			animations_player.play("jump")
			await animations_player.animation_finished
			animation_lock = false
	
	if Input.is_action_just_pressed("ui_dash"):
		if can_dash == true:
			can_dash = false
			block = true
		
	if block == true:
		if can_dash == false:
			velocity.x = player.scale.x * speed_dash
			dash_timer += delta
	
	if dash_timer >= dash_end:
		dash_timer = 0.0
		velocity.x = 0.0
		block = false
	
	if dash_timer == 0.0:
		dash_cooldown += delta
		if dash_cooldown >= dash_end_cooldown:
			can_dash = true
			dash_cooldown = 0.0
	
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_sit_down"):
		if sit_down == false:
			if animation_lock == false:
				animation_lock = true
				animations_player.play("climb")
				player_collision.shape.size.y = 185.0
				await animations_player.animation_finished
				animation_lock = false
				sit_down = true
		else:
			if animation_lock == false:
				if not check_celling.is_colliding():
					player_collision.shape.size.y = 234.0
					sit_down = false
					animations_player.play("idle")
	
	if Input.is_action_just_pressed("ui_pick_up"):
		var obj = check_take.get_collider() as RigidBody2D
		
		if take_cooldown == false:
			take_cooldown = true
			if pick == false:
				if obj != null:
					body(obj, "pick")
					picked_body = obj
					pick = true
			else:
				body(picked_body,"put")
				pick = false
			await get_tree().create_timer(take_cooldown_timer).timeout
			take_cooldown = false
	
	if picked_body != null:
		picked_body.global_position = picked_body.global_position.lerp(global_position + Vector2(player.scale.x * offset_take_body_x, offset_take_body_y), 0.4)


func body(_body, _action: String):
	picked_body = _body
	if _action == "pick":
		picked_body.collision_layer = 0
		picked_body.freeze = true
	elif _action == "put":
		picked_body.collision_layer = 1
		picked_body.freeze = false
		picked_body = null


func action(params: Dictionary, action_type: String) -> void:
	if action_type == "action":
		if params.has("energy"):
			Global.game_data["player"]["energy"] = params["energy"]["amount"]
			Global.action.emit("energy")
		elif params.has("repulsive"):
			if params["repulsive"]["force_x"] == true:
				velocity.x = sign(global_position.x - params["repulsive"]["position"].x) * 100 * params["repulsive"]["force"]
			if params["repulsive"]["force_y"] == true:
				velocity.y = sign(global_position.y - params["repulsive"]["position"].y) * 100 * params["repulsive"]["force"]
			if params["repulsive"]["wait"] == true:
				block = true
				await get_tree().create_timer(0.5).timeout
				block = false
		elif params.has("jump"):
			Global.game_data["player"]["jump_force"] = params["jump"]["jump_force"]
		elif params.has("gravity_change"):
			if gravity > 0:
				player.scale.y = -1.0
				player.position.y = -46.0
				gravity = params["gravity_change"]["force_gravity"]
			else:
				player.scale.y = 1.0
				player.position.y = 0.0
				gravity = -params["gravity_change"]["force_gravity"]
		elif params.has("damage"):
			Global.invicible = 1
			Global.game_data["player"]["health_human"] -= params["damage"]["amount"]
			Global.action.emit("health")
			if Global.game_data["player"]["health_human"] <= 0:
				Global.game_over.emit()
			await get_tree().create_timer(player_damage_timer).timeout
			Global.invicible = 0
	elif action_type == "reset":
		if params.has("jump"):
			Global.game_data["player"]["jump_force"] = params["jump"]["normal_jump_force"]
