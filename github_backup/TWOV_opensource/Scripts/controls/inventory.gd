extends Control

var path_items = "user://items_TWOV_test1290.cfg"
var current_slot = 1

@onready var control_gui = get_node_or_null("/root/level_2/mobile_control") if Global.type_level == "level_2" else null
@onready var slots = $slots

func save_items():
	var config_game = ConfigFile.new()
	config_game.set_value("items", "2items2", Global.items_inv)
	config_game.save(path_items)

func load_items():
	var config = ConfigFile.new()
	var err = config.load(path_items)
	
	if err == OK:
		Global.items_inv = config.get_value("items", "2items2", [])
		
		# Инициализируем пустые слоты, если их меньше чем нужно
		var slot_count = slots.get_child_count()
		while Global.items_inv.size() < slot_count:
			Global.items_inv.append({"name": "пусто", "use": true})
		
		# Обновляем интерфейс
		update_inventory_ui()

func update_inventory_ui():
	for i in range(slots.get_child_count()):
		var slot = slots.get_child(i)
		if slot.name.begins_with("slot_inventory_"):
			if i < Global.items_inv.size():
				var item = Global.items_inv[i]
				# Проверяем, что это действительный предмет
				if item is Dictionary and item.has("name") and item["name"] != "пусто" and item.get("use", false) == false:
					slot.text = str(item["name"])
				else:
					slot.text = "пусто"
			else:
				slot.text = "пусто"

func _ready():
	Global.item.connect(self._update_item_inv)
	Global.use.connect(self._on_item_used)
	load_items()

func _update_item_inv(item_data: Dictionary):
	# Ищем первый слот, который либо пустой, либо содержит использованный предмет
	for i in range(Global.items_inv.size()):
		var item = Global.items_inv[i]
		if item is Dictionary and (item.get("name", "") == "пусто" or item.get("use", true) == true):
			Global.items_inv[i] = item_data
			update_inventory_ui()
			save_items()
			return
	
	Global.items_inv.append(item_data)
	update_inventory_ui()
	save_items()

func _on_item_used(_item: Dictionary):
	update_inventory_ui()
	save_items()

func _input(event):
	if event.is_action_pressed("ui_cancel") and slots.is_visible_in_tree():
		control_gui._items_end()
