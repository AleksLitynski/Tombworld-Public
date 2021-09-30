class_name BTRandom
extends BTConditional

export(int, 0, 100) var odds: int = 50

func _pre_tick(agent: Node, blackboard: Blackboard) -> void:
	randomize()
	verified = rand_range(0, 100) <= odds
