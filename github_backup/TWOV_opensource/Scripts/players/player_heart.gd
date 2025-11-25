extends CharacterBody2D


@export var base_speed: float = 100.0

@onready var gui_animation = get_node("/root/level_2/gui_control/animation_collision/gui_animation")
@onready var animation_heart = $heart_animation

var level

@onready var REFERENCE_RESOLUTION = get_viewport().get_visible_rect().size


func _physics_process(_delta):
	if Global.animation == 2 and Global.pause == 0:
		var move_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		var viewport_size = get_viewport_rect().size
		var scale_factor = viewport_size.x / REFERENCE_RESOLUTION.x
		
		velocity = move_input * (base_speed * scale_factor)
		move_and_slide()

func damage():
	animation_heart.play("damage")
	Global.action.emit("health")
	if Global.player_list[0]["heart"] > 0:
		Global.invicible = 1
		await get_tree().create_timer(0.5).timeout
		Global.invicible = 0
	if Global.player_list[0]["heart"] <= 0:
		Global.game_over.emit()
		Global.player_list[0]["energy"] = 15
		Global.action.emit("health")
		Global.action.emit("energy")

func change_scene():
	get_tree().change_scene_to_packed(level)
