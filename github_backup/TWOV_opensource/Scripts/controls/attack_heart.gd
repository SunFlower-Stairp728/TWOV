extends Control

@onready var background_attack: ColorRect = $bar/background
@onready var progress_bar: ColorRect = $bar/background/progress
@onready var target_line: ColorRect = $bar/background/target
@onready var bar = $bar

var max_distance = 100.0
var speed_bar = 200.0

signal attack_finished(accuracy: float)

func _ready():
	# Инициализация размеров и позиций
	var screen_size = get_viewport().get_visible_rect().size
	bar.global_position = Vector2(screen_size.x / 2, screen_size.y / 1.5)
	background_attack.size = Vector2(300, 20)
	background_attack.position = Vector2(-150, -10)
	
	progress_bar.size = Vector2(10, 20)
	progress_bar.position = Vector2(background_attack.size.x, 0)
	
	target_line.size = Vector2(10, 30)
	target_line.position = Vector2(background_attack.size.x , -5)

func start_attack():
	target_line.position.x = background_attack.size.x / 6

func _process(delta):
	progress_bar.position.x -= delta * speed_bar
	if progress_bar.position.x <= background_attack.position.x / 15:
		emit_signal("attack_finished", 0.0)
		queue_free()

func finish():
	var distance = abs(progress_bar.position.x - target_line.position.x)
	var accuracy = 1.0 - (distance - max_distance)
	
	accuracy = clamp(accuracy, 0.0, 1.0)
	emit_signal("attack_finished", accuracy)
	queue_free()
