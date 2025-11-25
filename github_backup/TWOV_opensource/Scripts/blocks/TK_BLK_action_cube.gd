extends Node2D

@onready var animation = get_node_or_null("AnimationPlayer2D")
@onready var player = get_node("/root/level_2/player")

@onready var light = get_node("light")

var distance_current = 0.0
var distance_max = 300.0

@export var cube = "cube_1"
@export var index = 1

@onready var list_blocks = {
	"cube_1": {
		"color": "20d10f",
		"action": {"repulsive": {"position": global_position, "force_x": false, "force_y": true, "force": 16, "wait": false}}
	},
	"cube_2": {
		"color": "fed942",
		"action": {"jump": {"jump_force": Global.game_data["player"]["jump_force"] * 2.0, "normal_jump_force": Global.game_data["player"]["jump_force"]}}
	},
	"cube_3": {
		"color": "0000ff",
		"action": {"gravity_change": {"force_gravity": -0.05}}
	},
	"cube_4": {
		"color": "9537df",
		"action": {"energy": {"amount": 15}}
	},
	"cube_5": {
		"color": "25d93f",
		"action": {"energy": {"amount": 15}}
	},
	"cube_6": {
		"color": "ffffff",
		"action": null
	}
}

func _ready():
	_cube_apply_list()

func _cube_apply_list():
	light.color = list_blocks["cube_%s" % index]["color"]
	modulate = list_blocks["cube_%s" % index]["color"]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if list_blocks["cube_%s" % index]["action"] != null:
		if body.has_method("action"):
			body.action(list_blocks["cube_%s" % index]["action"], "action")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if list_blocks["cube_%s" % index]["action"] != null:
		if body.has_method("action"):
			body.action(list_blocks["cube_%s" % index]["action"], "reset")


func _process(_delta: float) -> void:
	distance_current = global_position.distance_to(player.global_position)
	
	if distance_current < distance_max and cube == "cube_6":
		if Input.is_action_just_pressed("ui_zoom"):
			index += 1
			if not "cube_%s" % index in list_blocks:
				index = 1
			_cube_apply_list()
