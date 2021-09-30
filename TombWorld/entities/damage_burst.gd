extends Particles

var start_time
func _ready():
	start_time = G.game_time
	
func _process(delta):
	if G.game_time - 2 > start_time:
		queue_free()
