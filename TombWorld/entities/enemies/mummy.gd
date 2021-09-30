extends Enemy

func _ready():
	$sprite.directions = [ { name = "arms" } ]
	$sprite/SwipePlayer.visible = false
	G.to_unique_materials($eye_mount/eye)
	
	$Blackboard.set_data("shot_data", {
		charge_mult = 2.0,
		discharge_mult = 1.5,
		current_aim_time = 0,
		aim_time = 0.2,
	})

func set_acting(should_act):
	if $behavior_tree.is_active == false and should_act == true:
		$behavior_tree.is_active = true
		$behavior_tree.start()
	else:
		$behavior_tree.is_active = should_act

func disable_self_get_sprite():
	$behavior_tree.is_active = false
	$CollisionShape.disabled = true
	return $sprite


func get_stun_bounds():
	return { x = Vector2(-0.5, 0.5), y = Vector2(0, 2), z = Vector2(-0.5, 0.5), stun_count = 20 }
