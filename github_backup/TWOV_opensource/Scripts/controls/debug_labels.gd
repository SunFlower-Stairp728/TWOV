extends Control

@onready var child = self.get_children()
var current_child = 0

var actions = {
	0: "fps",
	1: "size_lines"
}

var time_count = 0.0
@onready var time_wait = 0.3 / child.size()

func _process(delta):
	if not is_visible_in_tree():
		return
	
	time_count += delta
	if time_count > time_wait:
		time_count = 0.0
		if current_child < child.size():
			if actions[current_child] == "fps":
				child[current_child].text = str(child[current_child].name) + str(": %s" % round(Engine.get_frames_per_second()))
			elif actions[current_child] == "size_lines":
				child[current_child].text = str(child[current_child].name) + str(": %s" % Global.settings_game["display"]["point_position"].x)
			elif actions[current_child] == "rand":
				child[current_child].text = str(child[current_child].name) + str(": %s" % randi_range(1, 100))
			
			current_child += 1
		else:
			current_child = 0
