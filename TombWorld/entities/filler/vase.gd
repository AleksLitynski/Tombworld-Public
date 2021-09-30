extends Area


func _on_vase_body_entered(body):
	if body.is_in_group("bullet"):
		$AnimatedSprite3D.frames.set_animation_speed("default", 10)
		$AnimatedSprite3D.frames.set_animation_loop("default", false)
		$AnimatedSprite3D.play("default")
