extends Enemy

func _ready():
	$AnimatedSprite3D.directions = [
		{ name = "forward" },
		{ name = "frontangle" },
		{ name = "leftright" },
		{ name = "backangle" },
		{ name = "backward" },
		{ name = "backangle", flip = true },
		{ name = "leftright", flip = true },
		{ name = "frontangle", flip = true },
	]
	$AnimatedSprite3D.show_debug_lines = true

