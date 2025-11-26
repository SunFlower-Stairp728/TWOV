extends Control

var size_line = 0.0
@onready var screen_size = get_viewport_rect().size

func _ready():
	get_viewport().size_changed.connect(_lines)
	Global.apply_parametrs.connect(_lines)
	
	await get_tree().process_frame
	_lines()

func _lines():
	screen_size = get_viewport_rect().size
	size_line = int((screen_size.x - screen_size.y) / Global.settings_game["display"]["size_display"])
	
	for i in range(3):
		var line = get_node_or_null("line_%s" % i)
		if line:
			line.size = Vector2(size_line, screen_size.y)
			if line.name == "line_1":
				line.position = Vector2(0.0, 0.0)
			else:
				line.position = Vector2(screen_size.x - size_line, 0.0)
	Global.settings_game["display"]["size"].x = screen_size.x - (size_line * 2)
	Global.settings_game["display"]["size"].y = screen_size.y
	
	Global.settings_game["display"]["point_position"].x = size_line
	
	
