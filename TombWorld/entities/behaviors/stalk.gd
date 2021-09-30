extends BTNode
class_name BTStalk

export(float) var target_offset: float = 1.5
export(float) var good_enough_window: float = 0.05
export(float) var agent_height: float = 1.5


func in_range(agent):
	return G.player_pos().distance_to(agent.global_transform.origin) < target_offset

func in_decent_range(agent):
	var dist = G.player_pos().distance_to(agent.global_transform.origin)
	return dist + good_enough_window > target_offset and dist - good_enough_window < target_offset

# This is where the core behavior goes and where the node state is changed.
# You must return either succeed() or fail() (check below), not just set the state.
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	# if we're rougly close enough, exit
	var can_see_player = G.raycast_cansee(agent, G.player(), [agent_height, 1])
	if in_decent_range(agent) and can_see_player:
		agent.stop_moving()
		return succeed()

	# figure out if we're pusing in or pulling out
	var goal = "movein"
	agent.start_moving()
	if in_range(agent) and can_see_player:
		goal = "backoff"
		agent.speed *= 2

	# stalk for a random amount of time before we yield to other actions
	randomize()
	var max_stalk_time = rand_range(0.3, 1.0)
	var start_time = G.game_time

	while start_time > G.game_time - max_stalk_time:
		if agent.is_stunned():
			agent.stop_moving()
			if goal == "backoff": agent.speed *= 0.5
			return fail()

		# get a vector towards our target (either back off or move in)
		agent.target = agent.vec_to_target(G.player_pos()) \
			if goal == "movein" \
			else G.at_height((agent.global_transform.origin - G.player_pos()), 0).normalized()

		# we've succeeded if we're close enough or far enough away, per mode
		var at_goal = in_range(agent)
		if goal == "backoff": at_goal = not at_goal
			
		if at_goal and G.raycast_cansee(agent, G.player(), [agent_height, 1]):
			if goal == "backoff": agent.speed *= 0.5
			agent.stop_moving()
			return succeed()

		yield(get_tree(), "idle_frame")
	
	if goal == "backoff": agent.speed *= 0.5
	return fail()
