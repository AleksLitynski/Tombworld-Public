extends RigidBody

func _bullet_setup_complete():
	randomize()
	var direction = -transform.basis.z
	direction.y += 0.3
	var cone_size = 0.3
	direction.y += rand_range(-cone_size, cone_size)
	direction += direction.rotated(Vector3.UP, rand_range(-cone_size, cone_size))
	direction = direction.normalized() * 6
	gravity_scale = 0.5
	
	apply_central_impulse(direction + (G.swizzle("x_z", G.player().velocity) * 0.8))
	
	$sprite.scale = Vector3(0.3, 0.3, 0.3)

var body_state
func _integrate_forces(state):
	body_state = state

func _process(delta):
	var new_scale = G.step_towards($sprite.scale.x, 1.5, delta * 5)
	$sprite.scale = Vector3(new_scale, new_scale, new_scale)

func _on_slime_ball_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"): body.take_damage("slime_ball")
		yield(pop(true), "completed")
	
	elif body.is_in_group("slime_puddle"):
		body.grow_puddle(0.1)
		yield(pop(), "completed")
	else:
		var local_normal: Vector3 = body_state.get_contact_local_normal(0)
		var contact_point = body_state.get_contact_local_position(0)
		var puddle = preload("res://entities/slime_puddle.tscn").instance()
		G.common_root.add_child(puddle)
		puddle.global_transform.origin = body.global_transform.origin + contact_point
		puddle.global_transform = align_with_y(puddle.global_transform, local_normal)
		yield(pop(), "completed")

func pop(damage = false):
	# start to fade out
	G.tween_property($sprite, "modulate:a", 0.98, 0, 0.2, Tween.TRANS_LINEAR)
	$CollisionShape.disabled = true
	
	# show particles and wait a moment
	if damage:
		if $slime_damage/DamageParticles: $slime_damage/DamageParticles.emitting = true
	if $slime_damage/Particles: $slime_damage/Particles.emitting = true
	if get_tree(): yield(get_tree().create_timer(0.3), "timeout")
	if $slime_damage/Particles: $slime_damage/Particles.emitting = false
	if $slime_damage/DamageParticles: $slime_damage/DamageParticles.emitting = false
	if get_tree(): yield(get_tree().create_timer(1.0), "timeout")
	queue_free()

func align_with_y(xform, new_y):
	# taken from a tutorial somewhere :L
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
