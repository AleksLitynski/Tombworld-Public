extends Particles

func prep_cache():
	G.main.add_child(self)
	# put it 100 behind the camera
	self.global_transform.origin = G.camera().global_transform.origin - G.camera().global_transform.basis.z * 100
	amount = 1
	emitting = true
	get_tree().create_timer(1.0).connect("timeout", self, "_done_preloading")
	
func _done_preloading():
	queue_free()
