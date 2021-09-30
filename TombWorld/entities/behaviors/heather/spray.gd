extends BTNode
class_name BTHeatherSpray


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	agent.stop_moving()
	var scan_cone = agent.get_node("scan_cone")
	var anim = scan_cone.get_node("scan_cone_2/AnimationPlayer")
	var to_player = (agent.global_transform.origin - G.player_pos()).normalized()
	scan_cone.look_at(agent.global_transform.origin + to_player, Vector3.UP)
	anim.play("scan")
	yield(anim, "animation_finished")
	if agent.is_stunned(): return fail()
	
	# wait a second before we sneeze
	yield(get_tree().create_timer(0.5, false), "timeout")
	if agent.is_stunned(): return fail()
	
	var particles = scan_cone.get_node("Particles")
	particles.emitting = true
	agent.get_node("sfx").stream = preload("res://audio/sfx/enemy_spray.wav")
	agent.get_node("sfx").play()
	yield(get_tree().create_timer(0.5, false), "timeout")
	particles.emitting = false
	
	# check if we hit the player!
	var area = scan_cone.get_node("Area")
	if area.overlaps_body(G.player()):
		G.player().take_damage("heather_spray")
	
	yield(get_tree().create_timer(2.5, false), "timeout")
	return succeed()
