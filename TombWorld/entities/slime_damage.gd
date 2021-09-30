extends Spatial

var birth_time
func _ready():
	birth_time = G.game_time

func _process(delta):
	if G.game_time > birth_time + 4:
		queue_free()
