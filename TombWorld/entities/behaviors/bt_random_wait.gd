class_name BTRandomWait
extends BTNode

export(float) var min_wait = 0
export(float) var max_wait = 1

func _tick(agent: Node, blackboard: Blackboard):
	randomize()
	yield(get_tree().create_timer(rand_range(min_wait, max_wait), false), "timeout")
	return succeed()
