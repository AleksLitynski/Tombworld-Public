class_name BTLog
extends BTLeaf


export(String) var message: String
export(int, "In Game", "In Editor", "Both") var log_target: int

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	match log_target:
		0: # in game
			G.debug.log(message)
		1: # in editor
			print(message)
		2: # both
			G.debug.log(message)
			print(message)
	return succeed()
