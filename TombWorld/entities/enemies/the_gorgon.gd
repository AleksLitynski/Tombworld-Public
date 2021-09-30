extends Enemy

func _ready():
	$CollisionShape/sprite.directions = [ { name = "default" } ]
	health = 1000
	speed = 4500
	seperation = 12

func _process(delta):
	if G.at_height(_velo).length() > 0.2:
		$CollisionShape/sprite.play("default")
	else:
		$CollisionShape/sprite.stop()
	
	$eye_mount.look_at(G.at_height(G.player_pos(), $eye_mount.global_transform.origin.y), Vector3.UP)

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
	return { x = Vector2(-1.5, 1.5), y = Vector2(0, 4), z = Vector2(-1.5, 1.5), stun_count = 60 }
