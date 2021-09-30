extends Area


func _process(delta):
	transform.origin.y += sin(G.game_time) * 0.003

func _on_health_blob_body_entered(body):
	if body.is_in_group("player"):
		body.take_health("health_blob")
		queue_free()
