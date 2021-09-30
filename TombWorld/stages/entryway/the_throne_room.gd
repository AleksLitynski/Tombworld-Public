extends Spatial

func _ready():
	destroy_enemies_if_pit_not_clear()

func get_the_pits_entry():
	var key
	for k in G.game_state.stage_state.keys():
		if k.find("the_pits") != -1:
			key = k
			break
	if not key: return
	return G.game_state.stage_state[key]

func destroy_enemies_if_pit_not_clear():
	# start spawning enemies in the throne room after clearing the pit
	var pit_state = get_the_pits_entry()
	if not pit_state:
		$Navigation/enemies.queue_free()
		return
	if not pit_state.has("cleared"):
		$Navigation/enemies.queue_free()
		return
	if not pit_state.cleared:
		$Navigation/enemies.queue_free()
		return
