extends Node

@onready var visible_object = get_node_or_null("VisibleOnScreenNotifier2D")
@onready var sprite = get_node_or_null("Sprite2D")

var default_material : Material = null

func _ready():
	if sprite:
		if sprite.material != null:
			default_material = sprite.material
	_on_visible_on_screen_notifier_2d_screen_exited()


func _on_visible_on_screen_notifier_2d_screen_entered():
	process_mode = Node.PROCESS_MODE_INHERIT
	if get_class() == "Node2D":
		if sprite:
			if sprite.material == null:
				sprite.material = default_material
	elif get_class() == "PointLight2D":
		self.enabled = true
	if get_parent().get_class() == "RigidBody2D":
		get_parent().process_mode = Node.PROCESS_MODE_INHERIT
		get_parent().set_physics_process(true)
	elif get_parent().get_class() == "CharacterBody2D":
		get_parent().set_physics_process(true)
		if get_parent().name != "player":
			get_parent().process_mode = Node.PROCESS_MODE_INHERIT

func _on_visible_on_screen_notifier_2d_screen_exited():
	process_mode = Node.PROCESS_MODE_DISABLED
	if get_class() == "Node2D":
		if sprite:
			if sprite.material != null:
				sprite.material = null
	elif get_class() == "PointLight2D":
		self.enabled = false
	if get_parent().get_class() == "RigidBody2D":
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED
		get_parent().set_physics_process(false)
	elif get_parent().get_class() == "CharacterBody2D":
		get_parent().set_physics_process(false)
		if get_parent().name != "player":
			get_parent().process_mode = Node.PROCESS_MODE_DISABLED
