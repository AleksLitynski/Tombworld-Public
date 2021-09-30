extends Spatial

func _ready():
	$Navigation/pre_clear.visible = true
	$Navigation/post_clear.visible = true
	if G.game_state.stage_state.has(str(get_path())):
		var ss = G.game_state.stage_state[str(get_path())]
		if ss.has("cleared") and ss.cleared:
			$Navigation/pre_clear.queue_free()
			turn_on_lights()
		else:
			$Navigation/post_clear.queue_free()
	else:
		G.game_state.stage_state[str(get_path())] = {
			cleared = false
		}

func _process(delta):
	if not G.game_state.stage_state[str(get_path())].cleared \
		and ($Navigation/pre_clear/gordons.get_child_count() == 0) \
		and ($Navigation/pre_clear/heathers.get_child_count() == 0) \
		and ($Navigation/pre_clear/mummies.get_child_count() == 0):
			G.game_state.stage_state[str(get_path())].cleared = true
			$doors_and_gates/gate_1.open()
			$doors_and_gates/gate_2.open()
			turn_on_lights()


func turn_on_lights():
	G.tween_property($props/DirectionalLight2, "light_energy", 0, 100, 5, Tween.TRANS_LINEAR)
	G.tween_property($props/DirectionalLight3, "light_energy", 0, 100, 5, Tween.TRANS_LINEAR)
