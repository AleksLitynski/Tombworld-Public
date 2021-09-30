extends Gun


func _ready():
	._ready()
	G.player().action_manager.connect("trigger_pressed", self, "_fire_dome")
	bullets_ignore_player = false

func get_bounds():
	return Vector2(1200, 900)

func _fire_dome():
	for existing in get_tree().get_nodes_in_group("crystal"):
		existing.die()
	fire_bullet(preload("res://entities/crystal_dome.tscn").instance())
