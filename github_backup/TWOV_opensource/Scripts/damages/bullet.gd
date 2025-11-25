extends Node2D

# Добавляем экспортированные переменные
@export var scale_bullet = Vector2(1.6, 1.6)
@export var speed: float = 100.0
@export var damage_bullet: int = 5

@export var delete_timer: float = 0.0
@export var direction_gravity = Vector2(0.0, 0.0)  # По умолчанию вниз
@export var strength_gravity = 0.0

@export var is_homing: bool = false
@export var homing_target: CharacterBody2D = null
@export var homing_power: float = 0.1

@export var type = "bullet"

var direction := Vector2.ZERO
var velocity := Vector2.ZERO
@onready var animation := $Area2D/AnimationPlayer
@onready var animation_walk := $Area2D/AnimationPlayer2
@onready var notifier := $VisibleOnScreenNotifier2D
@onready var area_2d := $Area2D
@onready var bullet_centre = $Area2D/bullet_centre
@onready var bullet_body = $Area2D/bullet

@onready var REFERENCE_RESOLUTION = get_viewport().get_visible_rect().size

var fixed_direction = false

var _is_paused := false
var _scale_factor := 1.0

func _ready():
	if homing_target == null:
		homing_target = get_node("/root/level_2/mini_game/player_heart") if Global.type_level == "level_2" else get_node("/root/menu/CanvasLayer/menu/main_settings/Window/level_2/mini_game/player_heart") if Global.type_level == "menu" else null
	# Масштабируем пулю под текущий экран
	var viewport_size = get_viewport().get_visible_rect().size
	_scale_factor = viewport_size.x / REFERENCE_RESOLUTION.x
	self.scale = scale_bullet * _scale_factor/3.5
	
	animation.play("bullet_start")
	
	if type == "bullet":
		bullet_centre.modulate = Global.bullet_modulate
		animation_walk.play("walk")
	elif type == "hand":
		bullet_body.texture = preload("res://Sprite/entities/hand.png")
		bullet_centre.visible = false
	
	
	if delete_timer != 0.0:
		await get_tree().create_timer(delete_timer).timeout
		self.queue_free()

func _physics_process(delta):
	# Обработка самонаведения
	if is_homing and homing_target and is_instance_valid(homing_target):
		var target_direction = (homing_target.global_position - global_position).normalized()
		direction = direction.lerp(target_direction, homing_power * delta)
	
	# Основное движение: начальная скорость + гравитация
	var initial_velocity = direction * speed * _scale_factor
	var gravity_effect = direction_gravity * strength_gravity * delta
	
	velocity += gravity_effect
	
	position += (initial_velocity + velocity) * delta
	
	# Поворачиваем пулю по направлению движения (опционально)
	rotation = direction.angle()

func _disable_physics():
	self.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player_heart":
		if Global.invicible == 0 and Global.pause == 0 and Global.animation == 2:
			if Global.player_list.size() > 0:
				var damage = max(0, damage_bullet - Global.player_list[0]["defense"])
				Global.player_list[0]["heart"] -= damage
				Global.player_list[0]["defense"] = 0
				body.damage()

func _process(_delta):
	var new_pause_state = Global.pause != 0
	if new_pause_state != _is_paused:
		_is_paused = new_pause_state
		if _is_paused:
			if self.name.find("bullet"):
				animation.pause()
			set_physics_process(false)
		else:
			if self.name.find("bullet"):
				animation.play()
			set_physics_process(true)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	self.queue_free()
	
