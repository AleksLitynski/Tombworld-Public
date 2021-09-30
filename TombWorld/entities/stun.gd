extends AnimatedSprite3D

var lifetime = 5
var bounds
var die_time = 0
var spawn_point
var dying = false
func _ready():
	transform.origin = Vector3.ZERO
	die_time = G.game_time + lifetime
	randomize()
	spawn_point = transform.origin
	shuffle_pos()
	playing = false
	yield(get_tree().create_timer(rand_range(0, 1)), "timeout")
	playing = true

func _process(delta):
	if G.game_time > get_parent().get_parent().stun_end_time:
		dying = true
	
	if frame == 13:
		if dying:
			queue_free()
		else:
			shuffle_pos()

func shuffle_pos():
	randomize()
	transform.origin = spawn_point + Vector3(rand_range(bounds.x.x, bounds.x.y), rand_range(bounds.y.x, bounds.y.y), rand_range(bounds.z.x, bounds.z.y))
