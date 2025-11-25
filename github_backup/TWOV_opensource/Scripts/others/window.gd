extends Window

var scene = null

@onready var list_levels: Array = [
	load("res://Scenes/levels/level_fight.tscn"),
	load("res://Scenes/levels/worlds/level_0.tscn")
]

func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

func uptade_visible(action: bool):
	if action == true:
		process_mode = Node.PROCESS_MODE_INHERIT
		show()
	elif action == false:
		process_mode = Node.PROCESS_MODE_DISABLED
		hide()

func window(params: Dictionary = {}):
	uptade_visible(true)
	
	if params["type"] == "setting":
		size = Vector2(params["screen_size"].x / 4, params["screen_size"].y / 3)
		position = Vector2(params["screen_size"].x / 1.5, params["screen_size"].y / 8)
		borderless = false
		unresizable = false
	
	if scene == null:
		scene = list_levels[1]
		add_child(scene.instantiate())
		Global._load.emit(params["name_fight"])
	
