extends Arrow

func _ready():
	damage_type = "single_arrow"
	speed = 30

func set_heading_relative_to_parent(parent, heading):
	match heading:
		"forward":
			global_transform = parent.global_transform
		"left":
			global_transform = parent.global_transform.rotated(Vector3.UP, PI/2) # turn left
			 # if the parent was shot up or down, we want to get rid of that up/down direction and just go level left
			global_transform = G.looking_at_height(global_transform)
			 # position ourself at the parent
			global_transform.origin = parent.global_transform.origin
			
		"right":
			global_transform = parent.global_transform.rotated(Vector3.UP, -PI/2)
			global_transform = G.looking_at_height(global_transform)
			global_transform.origin = parent.global_transform.origin
