class_name BTDistanceToPlayer
extends BTConditional

export(int) var max_dist = 2

func _pre_tick(agent: Node, blackboard: Blackboard) -> void: 
	if agent is Spatial:
		verified = G.player_pos() \
			.distance_to(agent.global_transform.origin) \
			<= max_dist
	else:
		verified = false
