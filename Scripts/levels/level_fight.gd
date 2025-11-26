extends CanvasLayer

const BASE_ARENA_WIDTH_RATIO := 0.2
const BASE_WALL_THICKNESS_RATIO := 0.01


var bg_shader
var attack_bar = preload("res://Scenes/controls/attack_heart.tscn")
var attack_ui


@onready var main_level = get_node("/root/level_2") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2") if Global.type_level == "menu" else null

@onready var control_gui = get_node("/root/level_2/gui_control")
@onready var player = $player_heart
@onready var entity_sound = $sound_entity
@onready var entity = $entity
@onready var background_decor = $CanvasLayer/background_decor
@onready var background_fight = $CanvasLayer/background
@onready var background = $background


@onready var sound_effect = $sound_effect
@onready var fight_music = $fight

@onready var entity_texture
@onready var box = get_node("/root/level_2/gui_control/Control_heart/box_tools")
@onready var box_animations = get_node("/root/level_2/gui_control/Control_heart/box_tools/ColorRect/Animation")
@onready var message_fight = get_node("/root/level_2/gui_control/Control_heart/box_tools/message_fight")
@onready var health = get_node("/root/level_2/gui_control/bar/health")

@onready var animation_player = $player_heart/heart_animation
@onready var animation_entity = $entity/entity_animation

@onready var screen_size = get_viewport().get_visible_rect().size

var bullet_scene = preload("res://Scenes/damages/Bullet.tscn")
var laser_scene = preload("res://Scenes/damages/laser.tscn")

var obj_decor = preload("res://Scenes/decorations/fight_obj.tscn")


var examination_health

var attack_bar_instance = null
var attack_in_progress = false
var attack_result = 0.0
var attack_bar_speed = 0.5
var attack_target_position = 0.1
var attack_bar_progress = 0.0

var pos_entity: Vector2

var random_phase_boss = 1
var player_can_attack = true

var last_phase = 0

var current_boss
var boss_list

func _use_items(item: Dictionary):
	if item["name"] == "меч":
		Global.player_list[0]["add_damage"] = item["damage"]
	elif item["name"] == "зелье":
		
		Global.player_list[0]["heart"] += item["health"]
		Global.action.emit("health")
	
	

func _game_over():
	control_gui.visible_control(false, "Virtual Joystick")
	fight_music.stop()

func load_boss_structure(boss_name: String):
	var path_file_boss = "res://Scripts/levels/fights/%s.json" % boss_name
	var file = FileAccess.open(path_file_boss, FileAccess.READ)
	if file:
		boss_list = JSON.parse_string(file.get_as_text())
		file.close()
	
	_load_boss(boss_name)

func _load_boss(boss_name: String):
	current_boss = boss_name
	examination_health = boss_list[current_boss]["list_others"]["health"]
	
	entity_texture = load("res://Sprite/entities/%s.png" % current_boss)
	message_fight.text = boss_list[current_boss]["list_others"]["text"]
	entity_sound.stream = load("res://sounds/level sounds/entities/%s.mp3" % boss_list[current_boss]["list_others"]["sound_damage"])
	fight_music.stream = load("res://sounds/level sounds/fights/%s.mp3" % boss_list[current_boss]["theme"]["music"])
	
	bg_shader = preload("res://shaders/infinite_background.gdshader")
	
	background_fight.stretch_mode = TextureRect.STRETCH_TILE
	background_fight.texture = load(boss_list[current_boss]["theme"]["bg_fight_texture"])
	background_decor.texture = load(boss_list[current_boss]["theme"]["bg_fight_decor_texture"])
	background.texture = load(boss_list[current_boss]["theme"]["bg_arena_texture"])
	
	for s in boss_list[current_boss]["theme"]["bg_shaders"].size():
		background_fight.material.set_shader_parameter(boss_list[current_boss]["theme"]["bg_shaders"][str(s)]["name"], boss_list[current_boss]["theme"]["bg_shaders"][str(s)]["value"])
	
		
	for child in background.get_children():
		if child is StaticBody2D and child.name.begins_with("Wall_"):
			var visual = child.get_node("Visual") as ColorRect
			visual.modulate = Color(boss_list[current_boss]["theme"]["bg_arena_color"])
	
	background_fight.material.shader = bg_shader
	



func _ready():
	
	Global._load.connect(load_boss_structure)
	Global.use.connect(self._use_items)
	Global.game_over.connect(self._game_over)
	
	health.visible = true
	
	control_gui.visible_control(false, "Virtual Joystick")
	control_gui.visible_control(true, "select_buttons")
	control_gui.visible_control(false, "player_control")
	control_gui.select_act()
	
	create_arena()
	
	call_deferred("_initialize_layout")

	await get_tree().create_timer(1.0).timeout
	fight_music.play()

func _initialize_layout():
	if is_inside_tree():
		update_layout(screen_size)

func update_layout(current_size: Vector2):
	if current_size.x <= 0 or current_size.y <= 0:
		return
	
	var arena_dimension = min(current_size.x, current_size.y) * BASE_ARENA_WIDTH_RATIO
	var wall_thickness = current_size.y * BASE_WALL_THICKNESS_RATIO
	
	
	Global.apply_parametrs.emit()
	_update_arena(Vector2(arena_dimension, arena_dimension), wall_thickness)
	_position_entities(Vector2(arena_dimension, arena_dimension))

func _update_arena(arena_size: Vector2, wall_thickness: float):
	if background:
		background.size = arena_size
		background.position = screen_size/2 - arena_size/2
	
	
	_update_walls(arena_size, wall_thickness)

func _update_walls(arena_size: Vector2, wall_thickness: float):
	for child in background.get_children():
		if child is StaticBody2D and child.name.begins_with("Wall_"):
			var side = child.name.replace("Wall_", "")
			var visual = child.get_node("Visual") as ColorRect
			var collision = child.get_node("CollisionShape2D") as CollisionShape2D
			visual.z_index = 0
			match side:
				"top":
					visual.size = Vector2(arena_size.x, wall_thickness)
					collision.shape.size = visual.size
					visual.position = Vector2(0, 0)
				"bottom":
					visual.size = Vector2(arena_size.x, wall_thickness)
					collision.shape.size = visual.size
					visual.position = Vector2(0, arena_size.y - wall_thickness)
				"left":
					visual.size = Vector2(wall_thickness, arena_size.y)
					collision.shape.size = visual.size
					visual.position = Vector2(0, 0)
				"right":
					visual.size = Vector2(wall_thickness, arena_size.y)
					collision.shape.size = visual.size
					visual.position = Vector2(arena_size.x - wall_thickness, 0)
			
			collision.position = visual.position + visual.size / 2

func _position_entities(arena_size: Vector2):
	if player:
		player.position = background.position + arena_size / 2
		player.scale = Vector2(0.9, 0.9) * (arena_size.x / 1000.0)

	entity_position()

func create_arena():
	for child in get_children():
		if child.name.begins_with("Wall_"):
			child.queue_free()
	
	_create_wall("top")
	_create_wall("bottom")
	_create_wall("left")
	_create_wall("right")

func _create_wall(side: String):
	var wall = StaticBody2D.new()
	wall.name = "Wall_" + side
	
	var visual = ColorRect.new()
	visual.name = "Visual"
	
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = RectangleShape2D.new()
	
	wall.add_child(visual)
	wall.add_child(collision)
	background.add_child(wall)


func _get_random_phase():
	var phases_entity = boss_list[current_boss]["list_others"]["phases"]
	var possible_phases = Array(range(1, phases_entity + 1))
	
	
	# Если фаза уже была, убираем её из возможных
	if last_phase != 0:
		possible_phases.erase(last_phase)
	
	# Выбираем случайную фазу из оставшихся
	var new_phase = possible_phases[randi() % possible_phases.size()]
	last_phase = new_phase  # Запоминаем новую фазу
	
	return new_phase

func attack():
	if attack_in_progress == true:
		attack_ui.finish()
	else:
		start_attack_sequence()

func start_attack_sequence():
	player_can_attack = false
	attack_in_progress = true
	
	# Инициализация параметров атаки
	attack_bar_speed = 0.8  # Случайная скорость для разнообразия
	attack_bar_progress = 0.0
	
	# Создаем визуальные элементы атаки
	create_attack_ui()
	

func _on_attack_finished(accuracy: float):
	if attack_in_progress:
		finish_attack(accuracy)

func create_attack_ui():
	attack_ui = attack_bar.instantiate()
	attack_ui.position = Vector2(background.size.x / 2, background.size.y + 20)
	attack_ui.attack_finished.connect(self._on_attack_finished)
	add_child(attack_ui)
	attack_ui.start_attack()

func finish_attack(multiplier: float):
	if not attack_in_progress:
		return
	
	attack_in_progress = false
	attack_result = multiplier
	
	# Рассчитываем урон
	var base_damage = randi_range(3, 7)
	var final_damage = int(base_damage * (0.2 + 0.8 * multiplier)) + Global.player_list[0]["add_damage"]
	
	# Анимация атаки
	animation_player.play("attack")
	await animation_player.animation_finished
	
	if boss_list[current_boss]["list_others"]["health"] > 0:
		animation_entity.play("damage")
		entity_sound.play()
		boss_list[current_boss]["list_others"]["health"] -= final_damage
	
	
	if boss_list[current_boss]["list_others"]["health"] <= examination_health / 2:
		entity.material.set_shader_parameter("amplitude", 0.3)
		entity.material.set_shader_parameter("distortion", 0.04)
	if boss_list[current_boss]["list_others"]["health"] <= examination_health / 4:
		entity.material.set_shader_parameter("color_variation", 1.0)
		entity.material.set_shader_parameter("distortion", 0.06)
	
	print(boss_list[current_boss]["list_others"]["health"])
	
	if boss_list[current_boss]["list_others"]["health"] <= 0:
		entity.hide()
		fight_music.stop()
		
		control_gui.visible_control(false, "select_buttons")
		box.visible = false
		await get_tree().create_timer(2.0).timeout
		control_gui.animation.play("finish_scene")
		await control_gui.animation.animation_finished
		main_level.win()
		return
	
	await get_tree().create_timer(0.5).timeout
	start_enemy_attack()

func enemy_attack_finished():
	control_gui.select_act()
	control_gui.visible_control(false, "Virtual Joystick")
	player_can_attack = true
	update_layout(screen_size)

func _direction_entity():
	var arena_size = background.size
	var arena_pos = background.global_position
	var center_pos = arena_pos + arena_size / 2
	
	if entity.global_position > center_pos:
		entity.scale.x *= 1
	else:
		entity.scale.x *= -1

func start_enemy_attack():
	control_gui.visible_control(false, "select_buttons")
	control_gui.visible_control(true, "Virtual Joystick")
	Global.pause = 0
	var bullets = []
	Global.bullet_modulate = Color.from_hsv(randf(), 1.0, 1.0)
	random_phase_boss = _get_random_phase()
	box_animations.play("finish")
	await box_animations.animation_finished
	box.visible = false
	Global.animation = 2
	
	await get_tree().create_timer(0.5).timeout
	var arena_size = background.size
	var arena_pos = background.global_position
	var center_pos = arena_pos + arena_size / 2
	var player_pos = player.global_position
	
	match current_boss:
		"doll":
			match random_phase_boss:
				1:
					for i in range(8):
						var x = randf_range(arena_pos.x + 50, arena_pos.x + arena_size.x - 50)
						for j in range(3):
							var bullet = bullet_scene.instantiate()
							bullet.global_position = Vector2(x, arena_pos.y - 30 - j * 40)
							bullet.direction = Vector2(0, 1.0)
							bullet.speed = 90
							bullets.append(bullet)
							add_child(bullet)
						
						await get_tree().create_timer(0.4).timeout

				2: # Горизонтальные линии
					for i in range(8):
						var y = randf_range(arena_pos.y + 50, arena_pos.y + arena_size.y - 50)
						for j in range(3):
							var bullet = bullet_scene.instantiate()
							bullet.global_position = Vector2(arena_pos.x - 30 - j * 40, y)
							bullet.direction = Vector2(1, 0)
							bullet.speed = 90
							bullets.append(bullet)
							add_child(bullet)
						
						await get_tree().create_timer(0.4).timeout

				3:
					for i in range(6):
						for j in range(2):
							var bullet = bullet_scene.instantiate()
							var corner = Vector2(
								arena_pos.x + (j % 2) * arena_size.x,
								arena_pos.y + ((j + 1) % 2) * arena_size.y
							)
							bullet.global_position = corner + Vector2(
								(j % 2) * -60 - 30,
								((j + 1) % 2) * -60 - 30
							)
							bullet.direction = (player_pos - bullet.global_position).normalized()
							bullet.speed = 105
							bullets.append(bullet)
							add_child(bullet)
						
						await get_tree().create_timer(0.5).timeout

				4:
					for i in range(randi_range(1, 2)):
						for j in range(randi_range(3, 9)):
							var bullet = bullet_scene.instantiate()
							
							player_pos = player.global_position
							bullet.type = "hand"
							bullet.scale_bullet = Vector2(12.0, 12.0)
							bullet.global_position = Vector2(randf_range(0.0, screen_size.x), [0.0, screen_size.y][randi() % 2])
							bullet.direction = (player_pos - bullet.global_position).normalized()
							bullet.speed = 0
							bullet.damage_bullet = 10
							bullets.append(bullet)
							add_child(bullet)
						
						await get_tree().create_timer(1.5).timeout
						
						for bullet in bullets:
							if is_instance_valid(bullet):
								if randf() < 0.5 and bullet.fixed_direction == false:
									player_pos = player.global_position
									bullet.direction = (player_pos - bullet.global_position).normalized()
								bullet.fixed_direction = true
								bullet.speed = 300
								
								
								await get_tree().create_timer(randf_range(0.8, 1.5)).timeout
							else:
								continue
						await get_tree().create_timer(1.5).timeout

		"frog":
			match random_phase_boss:
				1:
					create_tween().tween_property(entity, "global_position", Vector2(center_pos.x, arena_size.y), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					await get_tree().create_timer(1.7).timeout
					
					for i in range(15):
						
						create_tween().tween_property(entity, "global_position", Vector2(center_pos.x, arena_pos.y - 70), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
						await get_tree().create_timer(0.2).timeout
						
						
						play_sound("bolt")
						for j in range(randi_range(1, 8)):
							var bullet = bullet_scene.instantiate()
							bullet.global_position = Vector2(randi_range(arena_pos.x, arena_pos.x + arena_size.x), arena_pos.y)
							bullet.direction = Vector2(randi_range(-1, 1), -1)
							bullet.direction_gravity = Vector2(0.0, 1.0)
							bullet.strength_gravity = 100.0
							bullet.speed = 50
							bullets.append(bullet)
							
							add_child(bullet)
							
							create_tween().tween_property(background, "position", Vector2(randi_range(arena_pos.x - 10, arena_pos.x + 10), arena_pos.y), 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							await get_tree().create_timer(0.05).timeout
							create_tween().tween_property(background, "position", arena_pos, 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
						
						create_tween().tween_property(entity, "global_position", Vector2(center_pos.x, arena_size.y), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
						await get_tree().create_timer(0.15).timeout

				2:
					for j in range(10):
						entity.global_position = Vector2(arena_pos.x + [0, arena_size.x][randi() % 2], arena_pos.y + arena_size.y)
						entity.scale = Vector2(0.15, 0.15)
						_direction_entity()
						
						
						if randf() < 0.8:
							var bullet = bullet_scene.instantiate()
							bullet.global_position = Vector2(entity.global_position)
							player_pos = player.global_position
							bullet.direction = (player_pos - bullet.global_position).normalized()
							bullet.speed = randi_range(150, 180)
							bullet.direction_gravity = Vector2(0.0, 1.0)
							bullet.strength_gravity = 100.0
							bullets.append(bullet)
							add_child(bullet)
						elif randf() < 1.0:
							await get_tree().create_timer(1.0).timeout
							play_sound("frog_shoot_language")
							var bullet = laser_scene.instantiate()
							player_pos = player.global_position
							
							bullet.global_position = entity.global_position
							bullet.max_length = arena_size.x * 1.8
							bullet.growth_speed = 400.0
							bullet.laser_thickness = 10.0
							bullet.damage = 2.0
							bullet.color = Color(1.0, 0.0, 0.0)
							
							var direction_player = (player_pos - bullet.global_position).normalized()
							
							bullet.initial_angle = direction_player.angle()
							bullet.auto_destroy = true
							bullet.is_growing = true
							bullets.append(bullet)
							add_child(bullet)
						
						await get_tree().create_timer(0.4).timeout

				3:
					for i in range(5):
						for j in range(1):
							var bullet = laser_scene.instantiate()
							
							entity.global_position = Vector2([arena_pos.x, arena_pos.x + arena_size.x][randi() % 2], [arena_pos.y, arena_pos.y + arena_size.y][randi() % 2])
							entity.scale = Vector2(0.2, 0.2)
							_direction_entity()
							await get_tree().create_timer(1.0).timeout
							play_sound("frog_shoot_language")
							player_pos = player.global_position
							
							bullet.global_position = entity.global_position
							bullet.max_length = arena_size.x * 1.8
							bullet.growth_speed = 500.0
							bullet.laser_thickness = 10.0
							bullet.damage = 5
							bullet.color = Color(1.0, 0.0, 0.0)
							
							var direction_player = (player_pos - bullet.global_position).normalized()
							
							bullet.initial_angle = direction_player.angle()
							bullet.auto_destroy = true
							bullet.is_growing = true
							bullets.append(bullet)
							add_child(bullet)
							await get_tree().create_timer(2.0).timeout

		"stasik":
			match random_phase_boss:
				1: # Вертикальные линии
					for i in range(5):
						var x = randf_range(arena_pos.x + 50, arena_pos.x + arena_size.x - 50)
						for j in range(3):
							var bullet = bullet_scene.instantiate()
							bullet.global_position = Vector2(arena_pos.x + [0, arena_size.x][randi() % 2], arena_pos.y + 30 + j * 40)
							bullet.direction = Vector2(randi_range(0, 1), randi_range(0, 1))
							bullet.speed = 60
							bullet.delete_timer = 5.0
							bullet.is_homing = true
							bullet.homing_power = 1.0
							bullets.append(bullet)
							add_child(bullet)
						
						await get_tree().create_timer(0.4).timeout
		
				2:
					for i in range(7):
						var y = randf_range(arena_pos.y + 50, arena_pos.y + arena_size.y - 50)
						for j in range(7):
							
							var bullet = bullet_scene.instantiate()
							entity.global_position = Vector2([center_pos.x - arena_size.x - 20, center_pos.x + arena_size.x + 20,][randi() % 2], [center_pos.y - arena_size.y, center_pos.y, center_pos.y + arena_size.y,][randi() % 2])
							entity.scale = Vector2.ONE * (arena_size.x / 550.0)
							bullet.global_position = entity.global_position
							player_pos = player.global_position
							bullet.direction = (player_pos - bullet.global_position).normalized()
							bullet.speed = 120
							bullets.append(bullet)
							add_child(bullet)
							
							
							await get_tree().create_timer(0.2).timeout
						await get_tree().create_timer(0.15).timeout

				3:
					for i in range(3):
						for j in range(10):
							var bullet = bullet_scene.instantiate()
								
							# Располагаем пули равномерно вокруг арены
							var angle = j * (2 * PI / 10) + i * 1.5 # 6 пуль = 60 градусов между каждой
							var radius = max(arena_size.x, arena_size.y) - 50  # Радиус немного больше арены
								
							# Вычисляем позицию пули по кругу
							var bullet_pos = center_pos + Vector2(cos(angle), sin(angle)) * radius
							
							bullet.global_position = bullet_pos
							bullet.scale_bullet = Vector2(1.7, 1.7)
							
							bullet.direction = -(bullet_pos - center_pos).normalized()
							bullet.speed = 0
							bullets.append(bullet)
							add_child(bullet)
							await get_tree().create_timer(0.1).timeout
						
						await get_tree().create_timer(0.5).timeout
						
						for bullet in bullets:
							if is_instance_valid(bullet):
								bullet.speed = 80
								await get_tree().create_timer(0.05).timeout
							else:
								continue
						await get_tree().create_timer(2.0).timeout

				4:
					for j in range(100):
						var bullet = laser_scene.instantiate()
						
						bullet.global_position = Vector2(center_pos)
						bullet.max_length = 1000.0
						bullet.growth_speed = 350.0
						bullet.laser_thickness = 7.0
						
						player_pos = player.global_position
						var direction_player = (player_pos - center_pos).normalized()
						
						bullet.initial_angle = direction_player.angle()
						bullet.auto_destroy = true
						bullet.is_growing = true
						bullets.append(bullet)
						add_child(bullet)
						await get_tree().create_timer(0.1).timeout

				5:
					for i in range(10):
						for j in range(1):
							var bullet = laser_scene.instantiate()
							
							bullet.global_position = Vector2([arena_pos.x, arena_pos.x + arena_size.x][randi() % 2], [arena_pos.y, arena_pos.y + arena_size.y][randi() % 2])
							bullet.max_length = 400.0
							bullet.growth_speed = 100.0
							bullet.laser_thickness = 10.0
							
							player_pos = player.global_position
							var direction_player = (player_pos - bullet.global_position).normalized()
							
							bullet.initial_angle = direction_player.angle()
							bullet.auto_destroy = true
							bullet.is_growing = true
							bullets.append(bullet)
							add_child(bullet)
						await get_tree().create_timer(2.0).timeout

		"spider":
			match random_phase_boss:
				1:
					for i in range(8):
						for j in range(2):
							if randf() < 0.85:
								for k in range(randi_range(1, 2)):
									var bullet = bullet_scene.instantiate()
									bullet.global_position = Vector2(entity.global_position)
									player_pos = player.global_position
									bullet.direction = Vector2(sign(player_pos.x - bullet.global_position.x), -1.0).normalized()
									bullet.speed = 220.0
									bullet.direction_gravity = Vector2(0.0, 1.0)
									bullet.strength_gravity = randf_range(115.0, 180.0)
									bullets.append(bullet)
									add_child(bullet)
									await get_tree().create_timer(0.1).timeout
								await get_tree().create_timer(0.15).timeout
							elif randf() < 1.0:
								var bullet = laser_scene.instantiate()
								
								bullet.global_position = Vector2(entity.global_position)
								bullet.max_length = screen_size.x
								bullet.growth_speed = randf_range(250.0, 300.0)
								bullet.laser_thickness = randf_range(5.0, 15.0)
								
								player_pos = player.global_position
								var direction_player = (player_pos - bullet.global_position).normalized()
								
								bullet.initial_angle = direction_player.angle()
								bullet.auto_destroy = true
								bullet.is_growing = true
								bullets.append(bullet)
								add_child(bullet)
								await get_tree().create_timer(1.3).timeout
		
				2:
					for i in range(4):
						for j in range(2):
							for k in range(randi_range(5, 8)):
								var bullet = bullet_scene.instantiate()
								bullet.global_position = Vector2(entity.global_position)
								player_pos = player.global_position
								bullet.direction = (player_pos - bullet.global_position).normalized()
								bullet.speed = 220
								bullets.append(bullet)
								add_child(bullet)
								await get_tree().create_timer(0.07).timeout
							await get_tree().create_timer(0.3).timeout

				3:
					for i in range(1):
						for j in range(10):
							var decor = obj_decor.instantiate()
							
							decor.global_position = Vector2(screen_size.x / 2, 0.0)
							decor.scale = Vector2(0.13, 0.13) * randf_range(1.0, 1.3)
							decor.change_texture("mini_spider")
							
							player_pos = player.global_position
							decor.direction = (player_pos - decor.global_position).normalized()
							decor.is_homing = true
							decor.homing_power = 10.0
							
							bullets.append(decor)
							add_child(decor)
							create_tween().tween_property(decor, "global_position", Vector2(arena_pos.x + [0, arena_size.x][randi() % 2], arena_pos.y + randf_range(0.0, arena_size.y)), randf_range(0.5, 0.8)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
						await get_tree().create_timer(randf_range(1.8, 2.5)).timeout 
					var dup_bullets = bullets.duplicate()
					for decor in dup_bullets:
						var bullet = laser_scene.instantiate()
						
						player_pos = player.global_position
						bullet.global_position = decor.global_position
						bullet.max_length = screen_size.length()
						bullet.growth_speed = 250.0
						bullet.laser_thickness = 3.0
						
						var direction_player = (player_pos - bullet.global_position).normalized()
						
						bullet.initial_angle = direction_player.angle()
						bullet.auto_destroy = true
						bullet.is_growing = true
						bullet.destroy_time = 1.0
						bullets.append(bullet)
						add_child(bullet)
						decor.is_homing = false
					dup_bullets.clear()

		"mr_signal":
			match random_phase_boss:
				1:
					var count = 0
					create_tween().tween_property(entity, "global_position", Vector2(pos_entity.x, -screen_size.y), 5.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
					background_fight.material.set_shader_parameter("speed", -30.0)
					for i in range(4):
						for j in range(4):
							for k in range(randi_range(1, 4)):
								var bullet = bullet_scene.instantiate()
								bullet.global_position = Vector2(screen_size.x / randf_range(1.8, 2.2), screen_size.y)
								player_pos = player.global_position
								bullet.direction = Vector2(0.0, -1.0)
								bullet.speed = randf_range(190.0, 220.0)
								bullets.append(bullet)
								add_child(bullet)
								await get_tree().create_timer(0.2).timeout
							await get_tree().create_timer(randf_range(0.1, 0.2)).timeout
							
						if count == 0:
							create_tween().tween_property(background, "position", Vector2(-screen_size.x / 3.8, 0.0), 5.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							count += 1
						elif count == 1:
							create_tween().tween_property(background, "position", Vector2(screen_size.x / 3.8, 0.0), 5.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							count = 0
							
						for b in range(randi_range(1, 4)):
							var decor = obj_decor.instantiate()
							decor.global_position = Vector2([screen_size.x / randf_range(1.2, 1.6), screen_size.x / randf_range(2.6, 3.0)][randi() % 2], screen_size.y)
							decor.direction = Vector2(0.0, -1.0)
							decor.speed = randf_range(190.0, 220.0)
							decor.scale = Vector2(0.2, 0.2)
							decor.change_texture("tv_1")
							bullets.append(decor)
							add_child(decor)
							await get_tree().create_timer(randf_range(0.3, 1.5)).timeout
							decor.change_texture("boom")
							play_sound("boom_2")
							for h in range(randi_range(2, 4)):
								var bullet = bullet_scene.instantiate()
								bullet.global_position = decor.global_position
								player_pos = player.global_position
								bullet.direction = Vector2([-1.0, 1.0][randi() % 2], [-1.0, 0.0, 1.0][randi() % 2])
								bullet.speed = 150.0
								bullets.append(bullet)
								add_child(bullet)
								await get_tree().create_timer(randf_range(0.05, 0.15)).timeout
							decor.queue_free()
						await get_tree().create_timer(randf_range(0.1, 0.2)).timeout
						
				
				2:
					var count = 0
					for i in range(3):
						for u in range(1):
							var tween = create_tween()
							var decor = obj_decor.instantiate()
							
							decor.change_texture("tv_1")
							decor.is_homing = true
							decor.homing_power = 10.0
							bullets.append(decor)
							add_child(decor)
							
							decor.global_position = Vector2([0.0, screen_size.x / 2, screen_size.x][randi() % 2], [0.0, screen_size.y][randi() % 2])
							decor.scale = Vector2(0.25, 0.25)
							tween.tween_property(decor, "position", Vector2(center_pos), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							
							await tween.finished
						
						for j in range(4):
							for k in range(5):
								var bullet = bullet_scene.instantiate()
								bullet.global_position = Vector2(center_pos)
								player_pos = player.global_position
								bullet.direction = (player_pos - bullet.global_position).normalized()
								bullet.speed = 220.0
								bullets.append(bullet)
								add_child(bullet)
								await get_tree().create_timer(0.07).timeout
							await get_tree().create_timer(0.3).timeout
						await get_tree().create_timer(0.1).timeout
						
						for l in range(1):
							var decor = obj_decor.instantiate()
							var tween = create_tween()
							decor.change_texture("tv_hand")
							player_pos = player.global_position
							decor.scale = Vector2(1.5, 1.5)
							var rand = randi_range(0, 1)
							if rand == 0:
								decor.global_position = Vector2(center_pos.x, 0.0 - 100.0)
								tween.tween_property(decor, "global_position", Vector2(center_pos.x, 0.0 + 50.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							else:
								decor.global_position = Vector2(center_pos.x, screen_size.y + 100.0)
								tween.tween_property(decor, "global_position", Vector2(center_pos.x, screen_size.y - 50.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							
							decor.direction = Vector2(0.0, player_pos.y - decor.global_position.y).normalized()
							bullets.append(decor)
							add_child(decor)
							
							
							
							if count == 0:
								create_tween().tween_property(background, "position", Vector2(0.0, -screen_size.y / 4), 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
								count += 1
							elif count == 1:
								create_tween().tween_property(background, "position", Vector2(0.0, screen_size.y / 4), 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
								count = 0
							
							await get_tree().create_timer(0.8).timeout
							play_sound("bolt")
						
							for j in range(1):
								var bullet = laser_scene.instantiate()
								
								bullet.global_position = Vector2(decor.global_position)
								bullet.max_length = screen_size.y
								bullet.growth_speed = 2800.0
								bullet.laser_thickness = 70.0
								bullet.damage = 10.0
								
								player_pos = player.global_position
								var direction_player = Vector2(0.0, player_pos.y - bullet.global_position.y).normalized()
								
								bullet.initial_angle = direction_player.angle()
								bullet.auto_destroy = true
								bullet.destroy_time = 1.5
								bullet.is_growing = true
								bullets.append(bullet)
								add_child(bullet)
							await get_tree().create_timer(1.5).timeout
						for decor in bullets:
							if is_instance_valid(decor):
								decor.queue_free()
						
				
				3:
					var count = 0
					for i in range(3):
						for j in range(3):
							var rand = [0.0 - arena_size.x, arena_size.x * 2][randi() % 2]
							for k in range(5):
								var bullet = bullet_scene.instantiate()
								bullet.global_position = Vector2(background.global_position.x + rand, background.global_position.y + randf_range(0.0, arena_size.y))
								player_pos = player.global_position
								bullet.direction =  Vector2(player_pos.x - bullet.global_position.x, 0.0).normalized()
								bullet.speed = 150.0
								bullets.append(bullet)
								add_child(bullet)
							await get_tree().create_timer(0.6).timeout
						await get_tree().create_timer(1.0).timeout
						
						for l in range(1):
							var decor = obj_decor.instantiate()
							var tween = create_tween()
							decor.change_texture("tv_hand")
							player_pos = player.global_position
							decor.scale = Vector2(1.5, 1.5)
							var rand = randi_range(0, 1)
							if rand == 0:
								decor.global_position = Vector2(center_pos.x, 0.0 - 100.0)
								tween.tween_property(decor, "global_position", Vector2(center_pos.x, 0.0 + 50.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							else:
								decor.global_position = Vector2(center_pos.x, screen_size.y + 100.0)
								tween.tween_property(decor, "global_position", Vector2(center_pos.x, screen_size.y - 50.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
							
							decor.direction = Vector2(0.0, player_pos.y - decor.global_position.y).normalized()
							bullets.append(decor)
							add_child(decor)
							
							
							if count == 0:
								create_tween().tween_property(background, "position", Vector2(0.0, screen_size.y / 4), 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
								count += 1
							elif count == 1:
								create_tween().tween_property(background, "position", Vector2(0.0, -screen_size.y / 4), 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
								count = 0
							
							await get_tree().create_timer(0.8).timeout
							play_sound("bolt")
							await get_tree().create_timer(0.1).timeout
							for j in range(1):
								var bullet = laser_scene.instantiate()
								
								bullet.global_position = decor.global_position
								bullet.max_length = screen_size.y
								bullet.growth_speed = 2400.0
								bullet.laser_thickness = 70.0
								bullet.damage = 10.0
							
								player_pos = player.global_position
								var direction_player = Vector2(0.0, player_pos.y - bullet.global_position.y).normalized()
								
								bullet.initial_angle = direction_player.angle()
								bullet.auto_destroy = true
								bullet.destroy_time = 1.5
								bullet.is_growing = true
								bullets.append(bullet)
								add_child(bullet)
							await get_tree().create_timer(1.5).timeout
						for decor in bullets:
							if is_instance_valid(decor):
								decor.queue_free()

	await get_tree().create_timer(5.0).timeout
	for bullet in bullets:
		if is_instance_valid(bullet):  # Проверяем, что пуля еще существует
			bullet.queue_free()
	bullets.clear()
	entity_position()
	enemy_attack_finished()

func entity_position():
	entity.texture = entity_texture
	
	if entity:
		if boss_list[current_boss]["list_others"]["position"] == "right":
			entity.global_position = Vector2(Global.settings_game["display"]["point_position"].x + Global.settings_game["display"]["size"].x - 150.0, screen_size.y / 2)
		elif boss_list[current_boss]["list_others"]["position"] == "up":
			entity.global_position = Vector2(Global.settings_game["display"]["size"].x / 2, screen_size.y / 4)
	pos_entity = entity.global_position

func play_sound(sound: String):
	var sound_path = "res://sounds/level sounds/effects/%s.mp3" % sound
	var sound_load = load(sound_path)
	if sound_load:
		sound_effect.stream = sound_load
		sound_effect.play()

func _process(_delta: float) -> void:
	if player:
		var new_position = player.global_position
		var radius = (Global.settings_game["display"]["size"] * BASE_WALL_THICKNESS_RATIO) * 1.2
		var rect_bg = Rect2(background.global_position, background.size)
		new_position.x = clamp(new_position.x, rect_bg.position.x + radius.x, rect_bg.end.x - radius.x)
		new_position.y = clamp(new_position.y, rect_bg.position.y + radius.y, rect_bg.end.y - radius.y)
		player.global_position = new_position
