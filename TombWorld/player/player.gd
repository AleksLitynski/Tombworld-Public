extends KinematicBody

signal do_flash(flash_color)

var gravity = -22
var coyote_time_gravity = -15
var max_fall_speed = -18

var accel = 70
var air_accel = 20
var freeze_accel = false

var decel_coe = .77
var air_decel_coe = .96

var max_speed_first_input = 15
var max_speed_input = 5.5
var max_speed_air = 6.0
var max_speed = 45
var apply_jump_speed = 0

var mouse_sensitivity = 0.0015

var looking_at = null
var freeze_input = false

var no_clip = false

var velocity = Vector3()
var air_heading_vel = Vector3()

var on_floor = true
var time_on_floor = 0
var time_in_air = 0
var on_ceil = false

var action_queue = []

onready var gun_manager = $Gun_Manager
onready var action_manager = $Action_Manager

var active_powers = []

var screen_flash

func xzlen(vec3):
	return sqrt((vec3.x * vec3.x) + (vec3.z * vec3.z))

class jump_manager:
	var charges = 0
	var charges_max = 1
	
	var floor_lock = 0
	
	var coyote_time = .2
	
	var button_pressed = false
	var button_released = false
	var button_held_time = 0
	var is_active = false
	var first_frame = false
	var time_active = 0
	var jump_speed = 13
	var max_jump_speed = 11
#	var burst_percentage = .5 setget balance_burst_time
#	func balance_burst_time(new_burst_tail_time):
#		if (new_burst_tail_time > 1): new_burst_tail_time = 1 % new_burst_tail_time
#		burst_percentage = new_burst_tail_time
#	var burst_time setget ,burst_time_get
#	func burst_time_get(): return duration * self.burst_percentage
#	var tail_accel = 5
#	var tail_time setget ,tail_time_get
#	func tail_time_get(): return duration * (1 - self.burst_percentage)

class glide_manager:
	var glide_power = 100
	var max_fall_speed = -3
	var gravity = -4
	var active = false
	var deadening_burst = false

class dash_manager: 
	var button_pressed = false
	var button_held_time = 0
	var active = false
	var time_active = 0
	var in_burst = false
	var duration = .5
	var burst_accel = 350
	var speed = 45
	
	var charges = 0
	var charges_max = 1
	
	var cooldown = 0
	var cooldown_add_time = .5
#	var burst_percentage = .4 setget balance_burst_time
#	func balance_burst_time(new_burst_tail_time):
#		if (new_burst_tail_time > 1): new_burst_tail_time = 1 % new_burst_tail_time
#		burst_percentage = new_burst_tail_time
#	var burst_time setget ,burst_time_get
#	func burst_time_get(): return duration * self.burst_percentage
#	var tail_accel = 280
#	var tail_time setget ,tail_time_get
#	func tail_time_get(): return duration * (1 - self.burst_percentage)
	
var jump = jump_manager.new()
var dash = dash_manager.new()
var glide = glide_manager.new()

func _ready():
	active_powers = G.game_state.stats.abilities
	screen_flash = setup_screen_flash()

func setup_screen_flash():
	if G.guns_overlay.get_node("screen_flash"):
		return G.guns_overlay.get_node("screen_flash")
	
	var r = ColorRect.new()
	r.anchor_left = 0
	r.anchor_top = 0
	r.anchor_bottom = 1
	r.anchor_right = 1
	r.color = Color(0, 0, 0, 0)
	r.name = "screen_flash"
	G.guns_overlay.add_child(r)
	return r
	

func get_input():
	var input_dir = Vector3()
	if not freeze_input:
		if Input.is_action_pressed("move_forward"):
			input_dir += -global_transform.basis.z
		if Input.is_action_pressed("move_back"):
			input_dir += global_transform.basis.z
		if Input.is_action_pressed("strafe_left"):
			input_dir += -global_transform.basis.x
		if Input.is_action_pressed("strafe_right"):
			input_dir += global_transform.basis.x
	
	input_dir = input_dir.normalized()
	return input_dir


func _input(event):
	if not freeze_input:
		if event.is_action_pressed("jump"):
			jump.button_pressed = true
		elif event.is_action_released("jump"):
			jump.button_pressed = false
		
		if event.is_action_pressed("dash"):
			dash.button_pressed = true
		elif event.is_action_released("dash"):
			dash.button_pressed = false
		
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * mouse_sensitivity)
			$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
			$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.5, 1.5)

func _process(delta):
	kill_if_oob()
	looking_at = compute_looking_at()
	on_floor = is_on_floor()
	on_ceil = is_on_ceiling()
	active_powers = G.game_state.stats.abilities
	if not no_clip:
		if on_floor:
			if time_on_floor == 0:
				glide.deadening_burst = true
				jump.charges = jump.charges_max
				glide.active = false
			time_in_air = 0
			time_on_floor += delta
			air_heading_vel = velocity
			air_heading_vel += air_heading_vel.normalized()
			air_heading_vel.y = 0
		else:
			if jump.charges == jump.charges_max and time_in_air > jump.coyote_time:
				jump.charges -= 1
			time_on_floor = 0
			time_in_air += delta
		process_jump_button(delta)
		process_dash_button(delta)

func activate_glide():
	if glide.deadening_burst and velocity.y < 0:
		velocity.y = 0
		glide.deadening_burst = false
	if velocity.y < -11:
		velocity.y = 0
		glide.deadening_burst = false
	else:
		apply_jump_speed = min(5, apply_jump_speed)
	glide.active = true
	

func process_jump_button(delta):
	var in_vec: Vector3 = get_input()
	
	if jump.button_pressed:
		var in_coyote_time = (jump.charges > 0 and time_in_air < jump.coyote_time)
		if jump.button_held_time == 0 and not in_coyote_time and not on_floor and active_powers.has("glide"):
			activate_glide()
		elif jump.charges > 0 and jump.button_held_time == 0: #and jump.button_released
			apply_jump_speed += jump.jump_speed
			jump.charges -= 1
			jump.first_frame = true
			if jump.charges < jump.charges_max:
				velocity += in_vec * 1000 * delta
#			time_on_floor = 0
			jump.time_active = 0
		else:
			jump.time_active += delta

		jump.button_held_time += delta
	else:
		if jump.time_active > 0:
			if apply_jump_speed > jump.max_jump_speed / 2:
				apply_jump_speed += -abs(apply_jump_speed * .38)
			jump.time_active = 0
		jump.button_held_time = 0
		glide.active = false
		
func process_dash_button(delta):
	if dash.cooldown > 0:
		dash.cooldown -= delta
	
	if dash.cooldown <= 0 and on_floor:
		dash.charges = dash.charges_max

	if dash.button_pressed:
		dash.button_held_time += delta
		if active_powers.has("dash") and dash.charges > 0:
			dash.charges -= 1
			dash.active = true
			$sfx.stream = preload("res://audio/sfx/dash.wav")
			$sfx.play()
	else: #released
		dash.button_held_time = 0
	
	if dash.active:
		dash.time_active += delta

	if dash.active and dash.time_active > .25:
		dash.active = false
		dash.cooldown = dash.cooldown_add_time
		dash.time_active = 0
		# automatically start gliding after we dash
		if active_powers.has("glide"):
			activate_glide()


func compute_looking_at():
	var ignore = get_tree().get_nodes_in_group("bullet")
	ignore.push_back(G.player())
	var res = G.raycast(
		G.camera().global_transform.origin,
		G.camera().global_transform.origin + G.camera().project_ray_normal(get_viewport().get_visible_rect().size / 2) * 100,
		ignore, [1, 3])
	if res:
		res["distance_to"] = res.position.distance_to(G.camera().global_transform.origin)
	
	var i = 0
	for j in get_tree().get_nodes_in_group("scannable"):
		i += 1
	return res

func _physics_process(delta):
	if no_clip:
		$CollisionBody.disabled = true
		$CollisionFeet.disabled = true
		no_clip_motion(delta)
	else:
		$CollisionBody.disabled = false
		$CollisionFeet.disabled = false
		normal_motion(delta)

func no_clip_motion(delta):
	if freeze_input: return
	var in_vec: Vector3 = get_input()
	if Input.is_action_pressed("jump"): in_vec.y = 2
	if Input.is_action_pressed("dash"): in_vec.y = -2
	velocity = move_and_slide(in_vec * 20, Vector3.UP)

var msp = 0
func normal_motion(delta):
	var in_vec: Vector3 = get_input()
	var frame_accel = accel
	var frame_decel_coe = decel_coe
	var frame_max_speed = max_speed_input
	var frame_gravity = gravity
	var init_vel = velocity
	var test = false
	
	if not on_floor and glide.active:
		frame_accel = air_accel
		frame_decel_coe = air_decel_coe
	
	if freeze_accel:
		frame_accel = 0
	
	if jump.first_frame:
		jump.first_frame = false
		frame_max_speed = max_speed_first_input
	
	if dash.active:
		if in_vec == Vector3.ZERO:
			# if the player is dashing and not pressing any buttons,
			# assume they want to dash forwards
			in_vec += -global_transform.basis.z
		frame_max_speed = dash.speed

	if in_vec.length() > 0:
		velocity += in_vec * frame_accel * delta
	else:
		if not on_floor and not glide.active:
			var air_v_pre = String(velocity)
			velocity.x *= frame_decel_coe
			velocity.z *= frame_decel_coe
			var air_v_post = String(velocity)
			if (abs(velocity.x) < .5): velocity.x = 0
			if (abs(velocity.z) < .5): velocity.z = 0
		else:
			velocity.x *= frame_decel_coe
			velocity.z *= frame_decel_coe
			if (abs(velocity.x) < .5): velocity.x = 0
			if (abs(velocity.z) < .5): velocity.z = 0

	var xzv = G.swizzle("x_z", velocity)
	var current_speed = xzv.length()
	if dash.active or current_speed > min(frame_max_speed, max_speed):
		var xzvn = xzv.normalized()
		velocity.x = xzvn.x * frame_max_speed
		velocity.z = xzvn.z * frame_max_speed
	
	if time_in_air < jump.coyote_time:
		frame_gravity = coyote_time_gravity * delta
	elif glide.active:
		frame_gravity = glide.gravity * delta
	else:
		frame_gravity = gravity * delta
	
	var actual_jump_speed = 0
	if not dash.active:
		move_lock_y = false
		if (apply_jump_speed > 0):
			if on_ceil:
				apply_jump_speed = min(apply_jump_speed, 1)
			apply_jump_speed += frame_gravity
			actual_jump_speed = clamp(apply_jump_speed, -jump.max_jump_speed, jump.max_jump_speed)
			velocity.y = actual_jump_speed
		else:
			velocity.y += frame_gravity
	else:
		move_lock_y = true
		velocity.y = 0
	
	if glide.active:
		if velocity.y < glide.max_fall_speed:
			velocity.y = glide.max_fall_speed
	else:
		if velocity.y < max_fall_speed:
			velocity.y = max_fall_speed
	
	velocity = move_and_slide(velocity, Vector3.UP, true)

func take_damage(source):
	if G.current_menu_name == "game_over_menu": return # don't take damage if we're dead
	
	# attack names come in as a string, we look up the damage based on a table
	var damage = G.data_tables.damage_values[source] if G.data_tables.damage_values.has(source) else G.data_tables.damage_values.default
	
	# if we don't have HP, we can't die
	if not G.game_state.has("stats"): return
	var stats = G.game_state.stats
	
	# consume all our tanks until we run out
	stats.health -= damage
	do_flash(Color.red)
	while stats.health <= 0:
		if stats.tanks <= 0:
			die()
			return
		else:
			stats.health += 100
			stats.tanks -= 1

func take_health(source):
	# fill current health bar
	var heal = G.data_tables.damage_values[source] if G.data_tables.damage_values.has(source) else G.data_tables.damage_values.default
	
	if not G.game_state.has("stats"): return
	var stats = G.game_state.stats
	
	stats.health += heal
	do_flash(Color.green)
	while stats.health > 100 and stats.tanks < stats.max_tanks:
		stats.health -= 100
		stats.tanks += 1
	stats.health = min(stats.health, 100)

# if you're out of bounds for more than 5 seconds and not no_clipping, die
var oob_start_time
func kill_if_oob():
	if not oob_start_time:
		oob_start_time = G.game_time
		return
	if len(G.get_current_stages_names()) <= 0 and not no_clip:
		if oob_start_time + 5 < G.game_time:
			take_damage("die")
	else:
		oob_start_time = G.game_time

func die():
	G.load_menu("game_over_menu")

var flash_in_progress = false
func do_flash(color):
	var time = 0.2
	var low = Color(color.r, color.g, color.b, 0)
	var high = Color(color.r, color.g, color.b, 0.4)
	if flash_in_progress: return
	flash_in_progress = true
	yield(G.tween_property(screen_flash, "color", low, high, time, Tween.TRANS_LINEAR), "completed")
	yield(G.tween_property(screen_flash, "color", high, low, time, Tween.TRANS_LINEAR), "completed")
	flash_in_progress = false
