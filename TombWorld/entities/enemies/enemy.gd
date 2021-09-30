extends KinematicBody
class_name Enemy

export(float) var health = 100
export(float) var speed = 200
export(bool) var flying = false
export(float) var fly_speed = 400

onready var _current_fly_speed = fly_speed
var fly_height = 5
onready var _current_speed = speed
var seperation = 4
var target = Vector3.ZERO
onready var _previous_target = target

var _velo = Vector3.ZERO
var _heading = Vector3(0, 0, 0)

var stun_end_time = 0
func set_stun_end_time(val): stun_end_time = val
var stun_host
func is_stunned(): return G.game_time < stun_end_time
var acting_lock = 0
var stun_is_active = false

signal should_die
var dying = false

func _ready():
	connect("should_die", self, "die")
	
	stun_host = Spatial.new()
	add_child(stun_host)
	stun_host.global_transform.origin = global_transform.origin

func safe_ray_target(target):
	return target == null or len(target.keys()) == 0 or target.collider == G.player()
	
func divide_above_below(steps, top, bottom):
	var test_points = [0]
	var towards_player = G.level_towards_player(self)
	var step = 1.0 / (steps + 1)
	var offset = step
	for i in range(steps):
		test_points.push_back(top * offset)
		test_points.push_back(bottom * offset)
		offset += step
	return test_points

# TODO: if 'flying' is true, we can choose a target in the air to climb over obstacles
func vec_to_target(target_true_pos):
	var nav: Navigation = G.get_parent_nav(self)
	
	# path straight to the player
	var target = target_true_pos
	
	# If we're on a nav mesh, use it to plan our route
	if nav:
		# find us, them, and a path on the nav mesh
		# the navmesh works in terms of its own coordinate system,
		# so convert our position and our target's positions to its local system, 
		# then convert everything back to global coords once we get a result
		var my_pos_local = nav.get_closest_point(nav.global_transform.xform_inv(global_transform.origin))
		var target_pos_local = nav.get_closest_point(nav.global_transform.xform_inv(target_true_pos))
		var path_to_player_local = nav.get_simple_path(my_pos_local, target_pos_local)
		var my_pos = nav.global_transform.xform(my_pos_local)
		var target_pos = nav.global_transform.xform(target_pos_local)
		var path_to_player = []
		for p in path_to_player_local:
			path_to_player.append(nav.global_transform.xform(p))

		# if the player is more than X units away from the edge of the navmesh, let them go
		# we want to more-or-less stick to our own nav meshes
		if G.at_height(target_pos).distance_to(G.at_height(target_true_pos)) > 10:
			return Vector3.ZERO
		
		# find a node that's more than 5 units away from the player (prevents twitching as we get close)
		for node in path_to_player: 
			if node.distance_to(global_transform.origin) > 5:
				target = node
				break

		if flying:
			# Subdivide the airspace above and below us into N segments
			var above = G.raycast_rel(global_transform.origin, Vector3.UP * 100, [self])
			var top = 100
			if above and above.position: top = above.position.y - global_transform.origin.y
			var below = G.raycast_rel(global_transform.origin, Vector3.DOWN * 100, [self])
			var bottom = -100
			if below and below.position: bottom = below.position.y - global_transform.origin.y
			var flight_levels = divide_above_below(3, top, bottom)

			# Take the path to the player and reverse it, so we an itterate from most ideal node to least ideal
			path_to_player.push_back(target_true_pos)
			path_to_player.invert()
			
			# For each point in the path, test each flight level...
			var found_target = false
			for next_point in path_to_player:
				for level in flight_levels:
					var global_level = global_transform.origin.y + level
					var origin_at_level = G.at_height(global_transform.origin, global_level) 
					var next_point_at_level = G.at_height(next_point, global_level)
					
					var direct_path = G.raycast(origin_at_level, next_point, [self, G.player()])
					var can_pass_direct = not (direct_path and direct_path.collider)
					if can_pass_direct and G.at_height(G.player_pos()).distance_to(G.at_height(global_transform.origin)) < 30:
						target = next_point
						target.y = target.y + fly_height
						found_target = true
						break

					var hit_flying = G.raycast(origin_at_level, next_point_at_level, [self, G.player()])
					var hit_target = G.raycast(next_point_at_level, next_point, [self, G.player()])
					var can_pass_flying = not (hit_flying and hit_flying.collider)
					var can_pass = not (hit_target and hit_target.collider)
					
					if can_pass_flying and can_pass:
						if level == 0:
							target = next_point_at_level
						else:
							target = origin_at_level
						found_target = true
						break

				if found_target:
					break

	# if we're withing 1.5 of the player, give up
	var to_target = (target - global_transform.origin).normalized()
	if (target_true_pos.distance_to(global_transform.origin) < 1.5):
		to_target = Vector3.ZERO

	# if we have a clear line of sight to the target, go after them
	if safe_ray_target(G.raycast_rel(global_transform.origin + Vector3.UP, to_target * seperation, [self])):
		return to_target

	# Otherwise, check if we have a clear path by turning slightly left or right
	var left_target = to_target.rotated(Vector3.UP, PI / 5)
	var right_target = to_target.rotated(Vector3.UP, -PI / 5)
	var left_dist = (left_target + global_transform.origin).distance_to(target)
	var right_dist = (right_target + global_transform.origin).distance_to(target) 
	var targets
	if left_dist < right_dist:
		targets = [left_target, right_target]
	else:
		targets = [right_target, left_target]
	for t in targets:
		if safe_ray_target(G.raycast_rel(global_transform.origin + Vector3.UP, t * seperation, [self])):
			return t
	
	# if we can't reach the next node by going forward, left, or right, just hold still
	return Vector3.ZERO

func stop_moving():
	_current_speed = 0
	_current_fly_speed = 0
	

func start_moving():
	_current_speed = speed
	_current_fly_speed = speed

func _physics_process(delta):
	if dying: return
	if is_stunned() and !stun_is_active:
		stun_is_active = true
		acting_lock += 1
	if not is_stunned() and stun_is_active:
		stun_is_active = false
		acting_lock -= 1
	
	set_acting(acting_lock <= 0)
		
		
	_heading = lerp (_heading, target, delta)
	var look_target = G.swizzle("x_z", global_transform.origin - _heading) + Vector3(0, global_transform.origin.y, 0)
	if global_transform.origin != look_target:
		look_at(look_target, Vector3.UP)

	# apply gravity
	if flying:
		_velo = _heading * Vector3(_current_speed, _current_fly_speed, _current_speed)
	else:
		_velo = _heading * _current_speed
	if !flying:
		if !is_on_floor():
			_velo = Vector3(0, -2000, 0)
		else:
			_velo += Vector3(0, -100, 0)

	# move
	move_and_slide(_velo * delta, Vector3.UP)

func take_damage(damage_type, context = null):
	if not G.data_tables.damage_values.has(damage_type): return
	var damage = G.data_tables.damage_values[damage_type]
	
	health -= damage
	if health <= 0:
		emit_signal("should_die")

func disable_self_get_sprite():
	pass
	
func set_acting(should_act):
	pass

func die():
	dying = true
	var particles = preload("res://entities/enemy_die.tscn").instance()
	
	# break ourself so we can't keep acting
	var sprite = disable_self_get_sprite()
	
	if has_meta("four_color_source"):
		get_meta("four_color_source").die()
	
	# if this enemy has a sprite, start to dissapear it
	if sprite:
		G.tween_property(sprite, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR)

	# add some particles to mask our exit
	G.common_root.add_child(particles)
	particles.global_transform = global_transform
	particles.global_transform.looking_at(G.player_pos(), Vector3.UP)
	particles.emitting = true

	yield(get_tree().create_timer(3), "timeout")

	G.common_root.remove_child(particles)
	particles.queue_free()
	
	randomize()
	var odds = rand_range(0, 100)
	if odds < 15:
		var hp_drop = preload("res://entities/health_blob.tscn").instance()
		G.get_node_stage(self).add_child(hp_drop)
		hp_drop.global_transform = global_transform.translated(Vector3.UP * 1.2)

	queue_free()

func damage_burst(damage_source, hit_position, amount = 100):
	# spawn damage burst
	var damage = preload("res://entities/damage_burst.tscn").instance()
	G.common_root.add_child(damage)
	damage.global_transform.origin = hit_position
	damage.global_transform.rotated(Vector3.UP, -damage_source.global_transform.basis.get_euler().y)
	damage.amount = amount
	damage.emitting = true

func apply_stun():
	if not is_stunned():
		var bounds = get_stun_bounds()
		for i in range(bounds.stun_count):
			var stun = preload("res://entities/stun.tscn").instance()
			stun.bounds = bounds
			stun.lifetime = 5
			stun_host.add_child(stun)
	set_stun_end_time(G.game_time + 5)

func get_stun_bounds():
	return { x = Vector2(-1, 1), y = Vector2(-1, 1), z = Vector2(-1, 1), stun_count = 20 }
