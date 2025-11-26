extends Area2D

# Настройки (можно менять в инспекторе)
@export var max_length: float = 500.0
@export var growth_speed: float = 300.0
@export var laser_thickness: float = 10.0
@export var initial_angle: float = 0.0
@export var auto_destroy: bool = true
@export var destroy_delay: float = 1.0
@export var rotation_speed: float = 0.0
@export var destroy_time: float = 0.0

@export var damage = 1.0

@export var color = Color(1.0, 1.0, 1.0)
@onready var visual_lazer = $ColorRect
@onready var shape_lazer = $CollisionShape2D

# Внутренние переменные
var current_length: float = 0.0
var is_active: bool = true
var is_growing: bool = true
var direction: Vector2 = Vector2.RIGHT

func _ready():
	visual_lazer.color = color
	self.rotation = initial_angle
	update_visuals()
	

# Основные методы управления
func shoot(shoot_direction: Vector2):
	set_direction(shoot_direction)
	is_active = true
	is_growing = true
	current_length = 0
	update_visuals()

func stop():
	is_growing = false
	if destroy_time != 0.0:
		await get_tree().create_timer(destroy_time).timeout
	if auto_destroy:
		queue_free()

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	rotation = direction.angle()
	update_visuals()

# Вспомогательные методы
func _process(delta):
	if !is_active: return
	
	if rotation_speed != 0:
		rotation += rotation_speed * delta
		direction = Vector2.RIGHT.rotated(rotation)
	
	if is_growing:
		current_length = min(current_length + growth_speed * delta, max_length)
		update_visuals()
		
		if current_length >= max_length:
			is_growing = false
			if auto_destroy:
				stop()

func update_visuals():
	visual_lazer.size = Vector2(current_length, laser_thickness)
	visual_lazer.pivot_offset = Vector2(0, laser_thickness / 2)  # Центрируем по Y
	visual_lazer.position = Vector2(0, -laser_thickness / 2)  # Позиционируем визуал
	
	shape_lazer.shape.size = visual_lazer.size
	shape_lazer.position = Vector2(current_length / 2, 0)

func _on_body_entered(body):
	if body.name == "player_heart":
		if Global.invicible == 0 and Global.pause == 0 and Global.animation == 2:
			if Global.player_list.size() > 0:
				Global.player_list[0]["heart"] -= damage 
				body.damage() 
