extends Control

var list_event ={
	1:"exit",
	2:"up",
	3:"down",
	4:"accept",
	5:"cancel"
}

var buttons
var pressed_buttons = {}

func position_buttons():
	if not is_inside_tree():
		return
	var screen_size = get_viewport().get_visible_rect().size
	var base_size = min(screen_size.x, screen_size.y)
	var scale_factor = base_size / Global.settings_game["gui"]["size_gui"]
	
	var btn_width = clamp(50 * scale_factor, 30, 120)
	var btn_height = clamp(50 * scale_factor, 30, 120)
	var btn_offset = clamp(15 * scale_factor, 10, 30)
	var btn_spacing = clamp(10 * scale_factor, 5, 20)
	var margin = Vector2(Global.settings_game["gui"]["margin_gui.x"], Global.settings_game["gui"]["margin_gui.y"])
	
	for button in buttons:
		if Global.settings_game["gui"]["left_mode"] == false:
			if self.name == "Control_player":
				btn_pos("left", btn_offset + margin.x, (screen_size.y - btn_height - btn_offset) - margin.y, btn_width, btn_height)
				btn_pos("right", (btn_width + 2*btn_offset) + margin.x, (screen_size.y - btn_height - btn_offset) - margin.y, btn_width, btn_height)
				btn_pos("jump", (screen_size.x - btn_width - btn_offset) - margin.x, (screen_size.y - btn_height - btn_offset) - margin.y, btn_width, btn_height)
				btn_pos("zoom", (screen_size.x - btn_width - btn_offset) - margin.x, (screen_size.y - 2*btn_height - btn_offset) - margin.y - btn_spacing, btn_width, btn_height)
				btn_pos("dash", (screen_size.x - 2*btn_width - 2*btn_offset) - margin.x, (screen_size.y - btn_height - btn_offset) - margin.y, btn_width, btn_height)
				btn_pos("down", (screen_size.x - 2*btn_width - 2*btn_offset) - margin.x, (screen_size.y - 2*btn_height - btn_offset) - margin.y - btn_spacing, btn_width, btn_height)
				btn_pos("sit_down", (screen_size.x - btn_width - btn_offset) - margin.x, (screen_size.y - 3.2*btn_height - btn_offset) - margin.y - btn_spacing, btn_width, btn_height)
				btn_pos("pick_up", (screen_size.x - 2*btn_width - 2*btn_offset) - margin.x, (screen_size.y - 2*btn_height - btn_offset) - margin.y - btn_spacing, btn_width, btn_height)
			elif self.name == "Control_buttons":
				btn_pos("cancel", (btn_width + 2*btn_offset) + margin.x, (screen_size.y - btn_height - btn_offset) - margin.y, btn_width, btn_height)
				btn_pos("accept", btn_offset + margin.x, (screen_size.y - btn_height - btn_offset) - margin.y, btn_width, btn_height)
				btn_pos("down", (screen_size.x - btn_width - btn_offset) - margin.x, (screen_size.y - btn_height - btn_offset) - margin.y, btn_width, btn_height)
				btn_pos("up", (screen_size.x - btn_width - btn_offset) - margin.x, (screen_size.y - 2*btn_height - btn_offset) - margin.y - btn_spacing, btn_width, btn_height)
				

func btn_pos(button: String, x, y, w, h):
	var btn = get_node_or_null(button)
	if btn:
		btn.position = Vector2(x, y)
		btn.size = Vector2(w, h)

func _ready():
	Global.apply_parametrs.connect(position_buttons)
	get_viewport().size_changed.connect(_size)
	
	buttons = get_children().filter(func(child): return child is Button)
	
	for button in buttons:
		button.connect("button_down", _on_button_down.bind(button))
		button.connect("button_up", _on_button_up.bind(button))
	position_buttons()

func _size():
	position_buttons()

func _on_button_down(button: Button):
	if button.is_visible_in_tree():
		var action = "ui_%s" % button.name
		if not list_event.values().has(button.name):
			Input.action_press(action)
			pressed_buttons[button] = action
		elif list_event.values().has(button.name):
			var input_event = InputEventAction.new()
			input_event.action = action
			input_event.pressed = true
			Input.parse_input_event(input_event)

func _on_button_up(button: Button):
	if button.is_visible_in_tree():
		if pressed_buttons.has(button):
			var action = pressed_buttons[button]
			Input.action_release(action)
			pressed_buttons.erase(button)

func _input(event):
	if event is InputEventScreenTouch:
		for button in buttons:
			if button.get_global_rect().has_point(event.position):
				if event.pressed and button.is_visible_in_tree():
					var action = "ui_%s" % button.name
					Input.action_press(action)
					pressed_buttons[button] = action
				else:
					if pressed_buttons.has(button):
						var action = pressed_buttons[button]
						Input.action_release(action)
						pressed_buttons.erase(button)
