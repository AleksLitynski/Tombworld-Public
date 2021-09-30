extends BTNode
class_name BTTheGordonShoot

onready var charge_particles = preload("res://entities/enemies/gordon_charge_particles.tscn")

var last_tick_time = null
func tick_delta():
	var delta = G.game_time - last_tick_time
	last_tick_time = G.game_time
	return delta

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var last_tick = G.game_time
	agent.stop_moving()
	
	randomize()
	var eye_mount = agent.get_node("eye_mount/point")

	# spawn a bullet a size 0 and make it incrementally bigger as it charges up
	var particles = []
	for i in range(5):
		var emitter = charge_particles.instance()
		particles.push_back(emitter)
		emitter.emitting = true
		emitter.amount = i
		eye_mount.add_child(emitter)
		emitter.global_transform.origin = eye_mount.global_transform.origin
		yield(get_tree().create_timer(0.1, false), "timeout")
		if agent.is_stunned():
			yield(free_particles(particles), "completed")
			return fail()
	yield(get_tree().create_timer(1, false), "timeout")
	yield(free_particles(particles), "completed")
	
	shoot_lazer(agent)
	yield(get_tree().create_timer(.15), "timeout")
	shoot_lazer(agent)
	yield(get_tree().create_timer(.15), "timeout")
	shoot_lazer(agent)

	return succeed()

func shoot_lazer(agent):
	var laser = preload("res://entities/bullets/laser.tscn").instance()
	var eye_mount = agent.get_node("eye_mount/point")
	laser.add_collision_exception_with(agent)
	laser.global_transform = eye_mount.global_transform
	laser.transform = laser.transform.scaled(G.v3(4))
	laser.source = "the_gorgon_shot"
	laser.speed = 24
	agent.get_node("sfx").stream = preload("res://audio/sfx/enemy_laser.wav")
	agent.get_node("sfx").play()
	laser.get_node("CollisionShape").disabled = false
	G.safe_add_child(G.common_root, laser)
	laser.global_transform.origin = eye_mount.global_transform.origin
	laser.look_at(G.player_pos() + Vector3(0, 1, 0), Vector3.UP)

func free_particles(particles):
	for emitter in particles:
		emitter.emitting = false
	yield(get_tree().create_timer(0.8, false), "timeout")
	for emitter in particles:
		emitter.queue_free()
	
