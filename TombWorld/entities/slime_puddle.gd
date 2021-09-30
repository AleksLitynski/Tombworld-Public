extends Area

var effected_enemies = {}

func _on_slime_puddle_area_entered(area):
	if area.is_in_group("slime_puddle"):
		if area.scale.x <= scale.x:
			area.queue_free()
			grow_puddle(area.scale.x * 0.25)

func _on_slime_puddle_body_entered(body):
	if body.is_in_group("slime_ball"):
		body._on_slime_ball_body_entered(self)
	
			
			# check if it has been long enough to effect 

var max_size = 10
var grow_hold = 4
func grow_puddle(factor):
	if scale.x < max_size:
		scale += Vector3(factor, 0, factor)
		last_grow = G.game_time
	
var last_grow = 0
func _process(delta):
	if G.game_time - grow_hold > last_grow:
		scale -= Vector3(1, 0, 1) * delta * 1
		if scale.x < 0.05:
			queue_free()
	
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy"):
			var path = body.get_path()
			if not effected_enemies.has(path):
				effected_enemies[path] = true
				if body.has_method("take_damage"): body.take_damage("slime_puddle")
				var particles = preload("res://entities/slime_damage.tscn").instance()
				G.common_root.add_child(particles)
				particles.global_transform.origin = body.global_transform.origin
				particles.get_node("Particles").emitting = true
				particles.get_node("DamageParticles").emitting = true
				yield(get_tree().create_timer(0.3), "timeout")
				particles.get_node("Particles").emitting = false
				particles.get_node("DamageParticles").emitting = false
				yield(get_tree().create_timer(1), "timeout")
				G.common_root.remove_child(particles)
				particles.queue_free()
				effected_enemies.erase(path)
				
