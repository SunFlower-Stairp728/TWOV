class_name VirtualJoystick
extends Control

@export var pressed_color := Color.GRAY
@export_range(0, 200, 1) var deadzone_size : float = 10
@export_range(0, 500, 1) var clampzone_size : float = 75
var input_pickable


@export var joystick_mode = 1

enum Visibility_mode {
	ALWAYS,
	TOUCHSCREEN_ONLY,
	WHEN_TOUCHED
}

@export var visibility_mode := Visibility_mode.ALWAYS
@export var use_input_actions := true
@export var action_left := "ui_left"
@export var action_right := "ui_right"
@export var action_up := "ui_up"
@export var action_down := "ui_down"

var is_pressed := false
var output := Vector2.ZERO
var _touch_index : int = -1

@onready var _base := $Base
@onready var _tip := $Base/Tip
@onready var _base_default_position : Vector2
@onready var _tip_default_position : Vector2
@onready var _default_color : Color = _tip.modulate

func _ready() -> void:
	joystick_mode = Global.settings_game["gui"]["joystick_mode"]
	
	
	if Global.settings_game["gui"]["left_mode"] == true:
		var screen_size = get_viewport_rect().size
		var control_x = screen_size.x - size.x
		position.x = control_x
	
	_base_default_position = _base.position
	_tip_default_position = _tip.position
	
	update_visibility()
	_update_processing()


func update_visibility() -> void:
	if visible != false:
		match visibility_mode:
			Visibility_mode.ALWAYS:
				show()
			Visibility_mode.TOUCHSCREEN_ONLY:
				if DisplayServer.is_touchscreen_available():
					show()
				else:
					hide()
			Visibility_mode.WHEN_TOUCHED:
				hide()

func _update_processing() -> void:
	if visible:
		set_process_input(visible)
		set_process_unhandled_input(visible)
		input_pickable = visible


func show() -> void:
	show()
	_update_processing()

func hide() -> void:
	hide()
	_update_processing()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_joystick_area(event.position) and _touch_index == -1:
				if joystick_mode == 2 or joystick_mode == 3 or (joystick_mode == 1 and _is_point_inside_base(event.position)):
					if joystick_mode == 2 or joystick_mode == 3:
						_move_base(event.position)
					if visibility_mode == Visibility_mode.WHEN_TOUCHED:
						show()
					_touch_index = event.index
					_tip.modulate = pressed_color
					_update_joystick(event.position)
					get_viewport().set_input_as_handled()
		elif event.index == _touch_index:
			_reset()
			if visibility_mode == Visibility_mode.WHEN_TOUCHED:
				hide()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_joystick(event.position)
			get_viewport().set_input_as_handled()
	if visible == true:
		show()
	else:
		hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible == false:
		return

func _move_base(new_position: Vector2) -> void:
	var scale = get_global_transform_with_canvas().get_scale()
	_base.global_position = new_position - (_base.pivot_offset * scale)

func _move_tip(new_position: Vector2) -> void:
	var scale = _base.get_global_transform_with_canvas().get_scale()
	_tip.global_position = new_position - (_tip.pivot_offset * scale)

func _is_point_inside_joystick_area(point: Vector2) -> bool:
	if visible == false:
		return false
		
	var x: bool = point.x >= global_position.x and point.x <= global_position.x + (size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= global_position.y and point.y <= global_position.y + (size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y

func _get_base_radius() -> Vector2:
	return _base.size * _base.get_global_transform_with_canvas().get_scale() / 2

func _is_point_inside_base(point: Vector2) -> bool:
	var _base_radius = _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = point - center
	return vector.length_squared() <= _base_radius.x * _base_radius.x

func _update_joystick(touch_position: Vector2) -> void:
	var _base_radius = _get_base_radius()
	var center : Vector2 = _base.global_position + _base_radius
	var vector : Vector2 = touch_position - center
	vector = vector.limit_length(clampzone_size)
	
	
	if joystick_mode == 3 and touch_position.distance_to(center) > clampzone_size:
		_move_base(touch_position - vector)
	
	_move_tip(center + vector)
	
	if vector.length_squared() > deadzone_size * deadzone_size:
		is_pressed = true
		output = (vector - (vector.normalized() * deadzone_size)) / (clampzone_size - deadzone_size)
	else:
		is_pressed = false
		output = Vector2.ZERO
	
	if use_input_actions and get_parent().visible == true:
		if output.x >= 0 and Input.is_action_pressed(action_left):
			Input.action_release(action_left)
		if output.x <= 0 and Input.is_action_pressed(action_right):
			Input.action_release(action_right)
		if output.y >= 0 and Input.is_action_pressed(action_up):
			Input.action_release(action_up)
		if output.y <= 0 and Input.is_action_pressed(action_down):
			Input.action_release(action_down)
		
		if output.x < 0:
			Input.action_press(action_left, -output.x)
		if output.x > 0:
			Input.action_press(action_right, output.x)
		if output.y < 0:
			Input.action_press(action_up, -output.y)
		if output.y > 0:
			Input.action_press(action_down, output.y)


func _reset():
	is_pressed = false
	output = Vector2.ZERO
	_touch_index = -1
	_tip.modulate = _default_color
	
	# Возвращаем в исходное положение с учетом масштаба
	_base.position = _base_default_position
	_tip.position = _tip_default_position
	
	if use_input_actions:
		for action in [action_left, action_right, action_down, action_up]:
			if Input.is_action_pressed(action):
				Input.action_release(action)
