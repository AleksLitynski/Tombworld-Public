extends Bullet
class_name Arrow

var damage_type = "t_arrow"
func _ready():
	$sprite.directions = [
		{ name = "back" },
		{ name = "quarter_angle" },
		{ name = "side" },
		{ name = "quarter_angle" },
		{ name = "head_on" },
		{ name = "quarter_angle", flip = true },
		{ name = "side", flip = true },
		{ name = "quarter_angle", flip = true },
	]
	speed = 50

var dying = false
func _process(delta):
	if dying: return
	var hit = move_and_collide(-global_transform.basis.z * delta * speed)
	
	if hit:
		if hit.collider.is_in_group("enemy"):
			# damage enemy
			if hit.collider.has_method("damage_burst"): hit.collider.damage_burst(self, hit.position)
			if hit.collider.has_method("take_damage"): hit.collider.take_damage(damage_type)
		speed = 0
		dying = true
		$CollisionShape.disabled = true
		yield(G.tween_property($sprite, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR), "completed")
		queue_free()
