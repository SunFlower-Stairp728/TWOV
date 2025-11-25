extends Control

@onready var category_buttons = $Categories/HBoxContainer
@onready var settings_container = $Settings/ScrollContainer/VBoxContainer
@onready var scroll = $Settings/ScrollContainer

var current_category := 0
var current_setting := 0
var categories := ["shaders", "gui", "display"]
var settings_elements := []
var is_editing := false
var is_in_category := false
var current_edit_control: Control = null
var input_repeat_timer := 0.05
var input_repeat_delay := 0.3
var input_repeat_speed := 0.05

func _ready():
	settings_elements.resize(categories.size())
	for i in range(categories.size()):
		settings_elements[i] = []
	
	for category in categories:
		var button = Button.new()
		button.text = category.capitalize()
		button.focus_mode = Control.FOCUS_NONE
		category_buttons.add_child(button)
	
	_load_category(0)
	_update_focus()

func _process(delta):
	if is_editing and input_repeat_timer > 0:
		input_repeat_timer -= delta

func _input(event):
	if not visible: return
	
	if event.is_action("ui_up") or event.is_action("ui_down") or event.is_action("ui_accept") or event.is_action("ui_cancel"):
		if is_editing:
			_handle_editing_input(event)
		else:
			_handle_normal_navigation(event)
		get_viewport().set_input_as_handled()

func _handle_editing_input(event):
	if current_edit_control is SpinBox:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			input_repeat_timer = input_repeat_delay
			_change_spinbox_value(event)
		elif event.is_action("ui_up") or event.is_action("ui_down"):
			if input_repeat_timer <= 0:
				input_repeat_timer = input_repeat_speed
				_change_spinbox_value(event)
		elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			get_viewport().set_input_as_handled()
	
	elif current_edit_control is OptionButton:
		if event.is_action_pressed("ui_up"):
			current_edit_control.selected = wrapi(current_edit_control.selected - 1, 0, current_edit_control.item_count)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			current_edit_control.selected = wrapi(current_edit_control.selected + 1, 0, current_edit_control.item_count)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			current_edit_control.release_focus()
			_end_editing()
			get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_accept"):
		if current_edit_control is OptionButton:
			_on_option_button_changed(current_edit_control.selected, current_edit_control.get_meta("setting_path"), current_edit_control.get_meta("values"))
		_end_editing()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_end_editing()
		get_viewport().set_input_as_handled()

func _handle_normal_navigation(event):
	if Global.type_menu == "settings":
		if event.is_action_pressed("ui_up"):
			if is_in_category:
				current_setting = wrapi(current_setting - 1, 0, settings_elements[current_category].size())
			else:
				current_category = wrapi(current_category - 1, 0, categories.size())
				_load_category(current_category)
			_update_focus()
			get_viewport().set_input_as_handled()
		
		elif event.is_action_pressed("ui_down"):
			if is_in_category:
				current_setting = wrapi(current_setting + 1, 0, settings_elements[current_category].size())
			else:
				current_category = wrapi(current_category + 1, 0, categories.size())
				_load_category(current_category)
			_update_focus()
			get_viewport().set_input_as_handled()
		
		elif event.is_action_pressed("ui_accept"):
			if is_in_category:
				_start_editing()
			else:
				is_in_category = true
				current_setting = 0
				_update_focus()
			get_viewport().set_input_as_handled()
		
		elif event.is_action_pressed("ui_cancel"):
			if is_editing:
				_end_editing()
				
				
			elif is_in_category:
				is_in_category = false
				_update_focus()
			else:
				_apply_and_exit()
			get_viewport().set_input_as_handled()

func _apply_and_exit():
	Global.save_game_settings()
	get_parent().get_node("Window").uptade_visible(false)
	Global.type_menu = "menu"
	
	get_parent().visible = false

func _change_spinbox_value(event):
	var spinbox: SpinBox = current_edit_control
	if event.is_action("ui_up"):
		spinbox.value += spinbox.step
	else:
		spinbox.value -= spinbox.step
	

func _start_editing():
	if Global.type_menu == "settings":
		if settings_elements[current_category].size() == 0: return
		
		var element = settings_elements[current_category][current_setting]
		current_edit_control = element
		is_editing = true
		
			
		if element is OptionButton:
			element.grab_focus()
			
			element.show_popup()
		elif element is CheckBox:
			element.button_pressed = !element.button_pressed
			_on_setting_changed(element.button_pressed, element.get_meta("setting_path"))
			
			_end_editing()
		elif element is HBoxContainer:
			var first_spin = _get_first_spinbox(element)
			if first_spin:
				current_edit_control = first_spin
				first_spin.grab_focus()
				first_spin.get_line_edit().select_all()
		
		_update_focus()

func _get_first_spinbox(hbox: HBoxContainer) -> SpinBox:
	for child in hbox.get_children():
		if child is SpinBox:
			return child
	return null

func _end_editing():
	if Global.type_menu == "settings":
		is_editing = false
		if current_edit_control is SpinBox:
			current_edit_control.get_line_edit().release_focus()
		elif current_edit_control is OptionButton:
			current_edit_control.release_focus()
		current_edit_control = null
		_update_focus()
		Global.apply_parametrs.emit()
		Global.save_game_settings()

func _load_category(category_idx: int):
	current_category = category_idx
	current_setting = 0
	
	for child in settings_container.get_children():
		child.queue_free()
	
	if settings_elements.size() <= category_idx:
		settings_elements.resize(category_idx + 1)
	settings_elements[category_idx] = []
	
	match categories[category_idx]:
		"shaders":
			_load_shader_settings()
		"gui":
			_load_gui_settings()
		"display":
			_load_display_settings()
	
	_update_focus()

func _create_settings_controls(settings_list: Array):
	for setting in settings_list:
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label = Label.new()
		label.text = setting["name"]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var control = _create_control_for_setting(setting, categories[current_category])
		settings_elements[current_category].append(control)
		
		hbox.add_child(label)
		hbox.add_child(control)
		settings_container.add_child(hbox)

func _create_control_for_setting(setting: Dictionary, category: String) -> Control:
	var current_value = Global.settings_game[category].get(setting["path"], 0.0)
	
	match setting["type"]:
		"number":
			var spinbox = SpinBox.new()
			spinbox.step = setting["step"]
			spinbox.max_value = setting["max"]
			spinbox.min_value = setting["min"]
			spinbox.value = current_value
			spinbox.set_meta("setting_path", setting["path"])
			spinbox.connect("value_changed", _on_setting_changed.bind(setting["path"]))
			return spinbox
		"bool":
			var checkbox = CheckBox.new()
			checkbox.button_pressed = current_value
			checkbox.set_meta("setting_path", setting["path"])
			checkbox.connect("toggled", _on_setting_changed.bind(setting["path"]))
			return checkbox
		"option":
			var option = OptionButton.new()
			for opt in setting["options"]:
				option.add_item(opt)
			if setting.has("values"):
				for i in range(setting["values"].size()):
					if setting["values"][i] == current_value:
						option.selected = i
						break
			else:
				option.selected = current_value
			option.set_meta("setting_path", setting["path"])
			option.set_meta("values", setting.get("values", []))
			option.connect("item_selected", _on_option_button_changed.bind(setting["path"], setting.get("values")))
			return option
	return Control.new()

func _on_setting_changed(value, setting_path: String):
	for category in categories:
		if Global.settings_game[category].has(setting_path):
			Global.settings_game[category][setting_path] = value
			break

func _on_option_button_changed(index, setting_path: String, values: Array):
	var value = values[index] if values else index
	for category in categories:
		if Global.settings_game[category].has(setting_path):
			Global.settings_game[category][setting_path] = value
			break
	

func _update_focus():
	for i in range(category_buttons.get_child_count()):
		var button = category_buttons.get_child(i)
		button.modulate = Color(1.0, 0.617, 0.913, 1.0) if (i == current_category and not is_in_category) else Color.WHITE
	
	for i in range(settings_elements[current_category].size()):
		var element = settings_elements[current_category][i]
		if is_editing and element == current_edit_control:
			element.modulate = Color(1, 1, 0.5)
		elif is_in_category and i == current_setting:
			element.modulate = Color(0.7, 0.7, 1.0)
		else:
			element.modulate = Color.WHITE
	
	if is_in_category and settings_elements[current_category].size() > current_setting:
		var element = settings_elements[current_category][current_setting]
		scroll.ensure_control_visible(element.get_parent())

func _load_display_settings():
	var settings_to_add = [
		{
			"path": "size_display",
			"name": "size display",
			"type": "option",
			"options": ["Fullscreen", "1:1", "10:4"],
			"values": [1000.0, 2.0, 3.0],
			"is_game_setting": true
		}
	]
	
	_create_settings_controls(settings_to_add)


func _load_shader_settings():
	var settings_to_add = [
		{
			"path": "color_bleed_intensity",
			"name": "color bleed intensity",
			"type": "number",
			"step": 0.1,
			"min": 0.0,
			"max": 0.8,
			"is_game_setting": true
		},
		{
			"path": "screen_curve",
			"name": "screen curve",
			"type": "number",
			"step": 0.1,
			"min": 0.0,
			"max": 0.5,
			"is_game_setting": true
		},
		{
			"path": "background_speed_1",
			"name": "background speed",
			"type": "option",
			"options": ["Off", "min", "default"],
			"values": [0.0, 0.4, 1.0],
			"is_game_setting": true
		},
	]
	
	_create_settings_controls(settings_to_add)

func _load_gui_settings():
	var settings_to_add = [
		{
			"path": "size_gui",
			"name": "size gui",
			"type": "number",
			"step": 50,
			"min": 300,
			"max": 1000,
			"is_game_setting": true
		},
		{
			"path": "left_mode",
			"name": "left mode",
			"type": "bool",
			"is_game_setting": true
		},
		{
			"path": "joystick_mode",
			"name": "joystick mode",
			"type": "option",
			"options": ["fixed", "dynamic", "following"],
			"values": [1, 2, 3],
			"is_game_setting": true
		},
		{
			"path": "margin_gui.x",
			"name": "margin buttons.x",
			"type": "number",
			"step": 50,
			"min": 0,
			"max": 500,
			"is_game_setting": true
		},
		{
			"path": "margin_gui.y",
			"name": "margin buttons.y",
			"type": "number",
			"step": 50,
			"min": 0,
			"max": 500,
			"is_game_setting": true
		}
	]
	
	_create_settings_controls(settings_to_add)
