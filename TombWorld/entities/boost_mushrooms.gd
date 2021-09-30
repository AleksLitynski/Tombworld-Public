extends Spatial

export(float) var stay_open_time = 10
export(float) var strength = 2200

var open_frame_time = 0.2
var opening = false

func _ready():
	$particles.emitting = false

func get_mushrooms():
	var mr = []
	for child in get_children():
		if child.name.find("mushroom_") == 0:
			mr.append(child)
	return mr

func open():
	var mushrooms = get_mushrooms()
	while mushrooms[0].frame < 5:
		for mushroom in mushrooms:
			mushroom.frame += 1
		yield(get_tree().create_timer(open_frame_time), "timeout")
	yield(get_tree(), "idle_frame")

func close():
	var mushrooms = get_mushrooms()
	while mushrooms[0].frame > 0:
		for mushroom in mushrooms:
			mushroom.frame -= 1
		yield(get_tree().create_timer(open_frame_time), "timeout")
	yield(get_tree(), "idle_frame")


func _on_Area_body_entered(body):
	if body.is_in_group("slime_ball") or body.is_in_group("slime_puddle"):
		if not opening:
			opening = true
			$particles.emitting = true
			yield(open(), "completed")
		$close_timer.start(stay_open_time)


func _on_close_timer_timeout():
	$particles.emitting = false
	yield(close(), "completed")
	opening = false

var velo_applied = Vector3.ZERO
func _physics_process(delta):
	var in_boost = false
	for b in $boost_area.get_overlapping_bodies():
		if b.is_in_group("player") and opening:
			var can_see = G.raycast(b.global_transform.origin, global_transform.origin, [b])
			if not can_see.has("collider"):
				var dist_to = clamp(b.global_transform.origin.distance_to(global_transform.origin) / 20, 0, 20) + 1
				velo_applied = global_transform.basis.y.normalized() * (strength / dist_to) * delta
				in_boost = true
	
	var friction = 10
	if G.player().is_on_floor() and not in_boost:
		velo_applied.y = 0
		friction = 30
	
	if velo_applied != Vector3.ZERO:
		velo_applied = G.player().move_and_slide(velo_applied, Vector3.UP)
	
	velo_applied.x = G.step_towards(velo_applied.x, 0, delta * friction)
	velo_applied.y = G.step_towards(velo_applied.y, 0, delta * friction)
	velo_applied.z = G.step_towards(velo_applied.z, 0, delta * friction)
