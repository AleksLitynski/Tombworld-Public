extends BTNode
class_name BTMummyMelee

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var sprite = agent.get_node("sprite")
	var player = agent.get_node("sprite/SwipePlayer")
	var volume = agent.get_node("Area")

	agent.stop_moving()
	agent._heading = (G.player_pos() - agent.global_transform.origin).normalized()
	agent.target = agent._heading

	sprite.directions = [ { name = "no_arms" } ]
	player.visible = true
	player.frame = 0
	player.play("motion")
	while player.playing:
		yield(player, "frame_changed")
		if player.frame + 1 == player.frames.get_frame_count("motion"):
			break
		if player.animation == "motion" and player.frame == 6:
			agent.get_node("sfx").stream = preload("res://audio/sfx/enemy_slash.wav")
			agent.get_node("sfx").play()
		if player.animation == "motion" \
			and player.frame == 6 \
			and volume.get_overlapping_bodies().has(G.player()):
			G.player().take_damage("mummy_melee")

	sprite.directions = [ { name = "arms" } ]
	player.visible = false
	player.stop()
	return succeed()
