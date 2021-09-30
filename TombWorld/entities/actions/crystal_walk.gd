extends Gun

var waiting_for_exit = []

func _ready():
	G.player().action_manager.connect("trigger_pressed", self, "enable")
	G.player().action_manager.connect("trigger_released", self, "disable")

func enable():
	for c in get_tree().get_nodes_in_group("crystal"):
		c.become_passable()


func disable():
	for c in get_tree().get_nodes_in_group("crystal"):
		c.become_impassable()
