extends Enemy

export(bool) var friendly = false

func _ready():
	$CollisionShape/sprite.directions = [ { name = "default" } ]
	seperation = 6
	fly_height = 2
	$scan_cone/scan_cone_2/AnimationPlayer.play("scan", -1, 0)
	if friendly:
		$"behavior_tree/BTSelector/20% chance we attack".is_active = false


func set_acting(should_act):
	if $behavior_tree.is_active == false and should_act == true:
		$behavior_tree.is_active = true
		$behavior_tree.start()
	else:
		$behavior_tree.is_active = should_act

func disable_self_get_sprite():
	$behavior_tree.is_active = false
	$CollisionShape.disabled = true
	return $CollisionShape/sprite

func get_stun_bounds():
	return { x = Vector2(-0.5, 0.5), y = Vector2(0.0, 0.5), z = Vector2(-0.5, 0.5), stun_count = 10 }
