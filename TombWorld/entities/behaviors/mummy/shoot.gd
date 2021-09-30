extends BTNode
class_name BTMummyShoot

var last_tick_time = null
func tick_delta():
	var delta = G.game_time - last_tick_time
	last_tick_time = G.game_time
	return delta

func turn_to_player(mount):
	if G.player():
		var player_pos = G.player_pos()
		player_pos.y = mount.global_transform.origin.y
		mount.look_at(player_pos, Vector3.UP)

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var last_tick = G.game_time
	var shot_data = blackboard.get_data("shot_data")
	agent.stop_moving()
	
	var aborted = false
		
	var mount: Spatial = agent.get_node("eye_mount")
	var light: OmniLight = agent.get_node("eye_mount/light")
	var eyeball: MeshInstance = agent.get_node("eye_mount/eye")

	# CHARGE
	last_tick_time = G.game_time
	G.set_alpha(eyeball, 0)
	light.light_energy = 0
	var alpha = 0
	while alpha < 1:
		# LOOP
		var delta = tick_delta()
		var mod_delta = delta * shot_data.charge_mult
		alpha += mod_delta
		G.set_alpha(eyeball, alpha)
		light.light_energy += mod_delta
		turn_to_player(mount)
		yield(get_tree(), "idle_frame")
		if agent.is_stunned():
			aborted = true
			break

	# AIM
	if not aborted:
		shot_data.current_aim_time = shot_data.aim_time
		last_tick_time = G.game_time
		while shot_data.current_aim_time > 0:
			var delta = tick_delta()
			shot_data.current_aim_time -= delta
			light.light_energy += delta * 25
			turn_to_player(mount)
			yield(get_tree(), "idle_frame")
			if agent.is_stunned():
				aborted = true
				break

	# FIRE
	if not aborted:
		var laser = preload("res://entities/bullets/laser.tscn").instance()
		laser.source = "mummy_shot"
		agent.get_node("sfx").stream = preload("res://audio/sfx/enemy_laser.wav")
		agent.get_node("sfx").play()
		G.common_root.add_child(laser)
		laser.add_collision_exception_with(agent)
		laser.global_transform.origin = agent.get_node("shoot_anchor").global_transform.origin
		laser.look_at(G.player_pos() + Vector3(0, 1, 0), Vector3.UP)

	# never abort the discharge. Always show a cool down
	# DISCHARGE
	alpha = G.get_alpha(eyeball)
	last_tick_time = G.game_time
	
	# LOOP
	while alpha > 0:
		var delta = tick_delta()
		var mod_delta = delta * shot_data.discharge_mult
		alpha -= mod_delta
		G.set_alpha(eyeball, alpha)
		if light.light_energy > 0:
			light.light_energy -= mod_delta * 5
		else:
			light.light_energy = 0
		yield(get_tree(), "idle_frame")
	
	# PREP NEXT
	G.set_alpha(eyeball, 0)
	light.light_energy = 0
		
	return succeed()
