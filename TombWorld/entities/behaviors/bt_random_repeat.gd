class_name BTRandomRepeat
extends BTRepeat

export(int) var min_repeat: int = 0
export(int) var max_repeat: int = 2

func _pre_tick(agent: Node, blackboard: Blackboard) -> void:
	randomize()
	times_to_repeat = (randi() % (max_repeat - min_repeat + 1)) + min_repeat
