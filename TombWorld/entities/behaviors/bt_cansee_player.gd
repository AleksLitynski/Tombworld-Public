class_name BTCanSeePlayer
extends BTConditional

export(float) var height = 1.5 

func _pre_tick(agent: Node, blackboard: Blackboard) -> void:
	verified = G.raycast_cansee(agent, G.player(), [height, 1])
