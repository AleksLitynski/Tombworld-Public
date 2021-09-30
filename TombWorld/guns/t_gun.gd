extends Gun

func _ready():
	._ready()
	G.player().gun_manager.connect("trigger_pressed", self, "_trigger_pressed")

var current_arrow
func _trigger_pressed():
	if not current_arrow:
		current_arrow = fire_bullet(preload("res://entities/bullets/t_arrow.tscn").instance())
		current_arrow.connect("tree_exiting", self, "current_arrow_exited")
	else:
		# delete the current arrow and fire 3 child single arrows in its place
		spawn_bullet_at_origin(preload("res://entities/bullets/single_arrow.tscn").instance()) \
			.set_heading_relative_to_parent(current_arrow, "forward")
		spawn_bullet_at_origin(preload("res://entities/bullets/single_arrow.tscn").instance()) \
			.set_heading_relative_to_parent(current_arrow, "left")
		spawn_bullet_at_origin(preload("res://entities/bullets/single_arrow.tscn").instance()) \
			.set_heading_relative_to_parent(current_arrow, "right")

		current_arrow.queue_free()
		current_arrow = null

func current_arrow_exited():
	current_arrow = null
