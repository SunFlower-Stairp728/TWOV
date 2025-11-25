class_name strench_mode
extends Node

#обычное расположение якорей но для нового экрана с полосками
enum custom_anchors_x {left, center, right}
enum custom_anchors_y {up, center, down}

enum size_type {testd, tests}

enum type {Control, Sprite2D}
@export var type_object = type.Control

@export_group("position_on_screen")
@export var X_current_anchor = custom_anchors_x.center
@export var Y_current_anchor = custom_anchors_y.center
@export var position_margin = Vector2(0.0, 0.0)
@export var wall_display = false

@export_group("size_on_display")
@export var fill_coefficient = Vector2(1.0, 1.0)
@export var size_margin = Vector2(0.0, 0.0)


func _ready():
	get_viewport().size_changed.connect(_screen)
	
	await get_tree().process_frame
	_screen()

func _screen():
	await get_tree().process_frame
	if fill_coefficient != Vector2(0.0, 0.0):
		if type_object == type.Control:
			self.size.x = Global.settings_game["display"]["size"].x / fill_coefficient.x
			self.size.y = Global.settings_game["display"]["size"].y / fill_coefficient.y
			self.size += size_margin
		elif type_object == type.Sprite2D:
			self.scale = Vector2(512.0, 512.0) / Global.settings_game["display"]["size"]
	
	print(Global.settings_game["display"]["point_position"].x)
	if X_current_anchor == custom_anchors_x.left:
		self.position.x = Global.settings_game["display"]["point_position"].x
	elif X_current_anchor == custom_anchors_x.center:
		self.position.x = Global.settings_game["display"]["point_position"].x + Global.settings_game["display"]["size"].x / 2 
	elif X_current_anchor == custom_anchors_x.right:
		self.position.x = (Global.settings_game["display"]["point_position"].x + Global.settings_game["display"]["size"].x)
		if wall_display == true:
			if type_object == type.Control:
				self.position.x -= self.size.x
		
	
	if Y_current_anchor == custom_anchors_y.up:
		self.position.y = Global.settings_game["display"]["point_position"].y
	elif Y_current_anchor == custom_anchors_y.center:
		self.position.y = Global.settings_game["display"]["point_position"].y + Global.settings_game["display"]["size"].y / 2 
	elif Y_current_anchor == custom_anchors_y.down:
		self.position.y = Global.settings_game["display"]["point_position"].y + Global.settings_game["display"]["size"].y
		if wall_display == true:
			if type_object == type.Control:
				self.position.y -= self.size.y
	
	self.position += position_margin
