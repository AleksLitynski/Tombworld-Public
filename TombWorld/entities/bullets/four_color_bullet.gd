extends Bullet
class_name FourColorBullet

var damage_type = "four_color_bullet"
var on_color_hit
var dying = false
func _physics_process(delta):
	if dying: return
	var hit = move_and_collide(-global_transform.basis.z * delta * speed)
	if hit:
		
		if hit.collider.is_in_group("doorshield"):
			hit.collider.take_damage(damage_type)

		if hit.collider.is_in_group("enemy"):
			hit.collider.damage_burst(self, hit.position, 20)
			hit.collider.take_damage(damage_type, { critical = hit.collider_shape.is_in_group("weak") })
		
		if hit.collider.has_meta("four_color_source") and on_color_hit and on_color_hit.is_valid():
			on_color_hit.call_func(hit.collider.get_meta("four_color_source"))

		dying = true
		$CollisionShape.disabled = true
		yield(G.tween_property($sprite, "modulate:a", 1, 0, 0.5, Tween.TRANS_LINEAR), "completed")
		queue_free()
