
extends Bullet

var lifetime = 0.75
var max_grow = 25
var spawn_time
var random_seed
var starting_velo = Vector3.ZERO
var confidence_factor = 0
var on_scan_hit

var grow_base = 0.1
func _ready():
	spawn_time = G.game_time
	speed = 15
	randomize()
	random_seed = rand_range(-1, 1)
	set_scale(grow_base)

var dying = false

func set_scale(s):
	$scan_ring.scale.x = s
	$scan_ring.scale.y = s
	$Area/CollisionShape.scale.x = s
	$Area/CollisionShape.scale.y = s

func set_scale_pulse(s):
	$scan_pulse.scale.x = s
	$scan_pulse.scale.y = s

func _process(delta):
	var cossize1 = cos(10 * (G.game_time - spawn_time + random_seed)) + 1
	cossize1 = clamp(cossize1, .7, 1.4)
	if not dying:
		grow_base += (delta * G.map_range(confidence_factor, 100, 0, 0, max_grow))
	else:
		grow_base += (delta * G.map_range(confidence_factor, 100, 0, 0, max_grow)) * 0.5
	set_scale(grow_base)
	set_scale_pulse(cossize1)
	# if we are 0% confident, do a big (*30) cone. If we're high confidence, do a small (*0) cone

	var percent_alive = 1 - ((G.game_time - spawn_time) / lifetime)

	if not dying:
		var color_lerp = confidence_factor / 100.0
		$scan_ring.modulate = Color.from_hsv(lerp(3 / 360.0, 188 / 360.0, confidence_factor / 100.0), 1, 1, percent_alive * 0.5)
		$scan_pulse.modulate.a = percent_alive

	var hit = move_and_collide(-global_transform.basis.z * delta * speed + (starting_velo * delta))
	if hit and not dying:
		if hit.collider.is_in_group("enemy"):
			hit.collider.apply_stun()
		
		if on_scan_hit and on_scan_hit.is_valid():
			on_scan_hit.call_func(hit)
		dying = true
	
	if G.game_time - spawn_time > lifetime:
		dying = true
	
	if dying:
		speed *= 0.1
		$CollisionShape.disabled = true
		if $scan_ring.modulate.a < 0:
			queue_free()
		else:
			G.tween_property($scan_pulse, "modulate:a", $scan_pulse.modulate.a, 0, $scan_pulse.modulate.a * 0.25, Tween.TRANS_LINEAR)
			yield(G.tween_property($scan_ring, "modulate:a", $scan_ring.modulate.a, 0, $scan_ring.modulate.a * 0.5, Tween.TRANS_LINEAR), "completed")
			queue_free()


func _on_Area_body_entered(body):
	if not dying and body.is_in_group("enemy"):
		body.apply_stun()
		dying = true
