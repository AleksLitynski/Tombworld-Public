extends Node

# Thanks godot docs https://docs.godotengine.org/en/stable/tutorials/io/background_loading.html
onready var stage_loader = preload("res://utils/stage_loader.gd").new()
onready var saves = preload("res://utils/saves.gd").new()
onready var strings = preload("res://utils/strings.gd").new()

onready var menu_root = get_singleton("menu_root")
onready var game_root = get_singleton("game_root")
onready var common_root = get_singleton("common_root")
onready var utils_root = get_singleton("utils_root")
onready var main = get_singleton("main_root")
onready var debug = get_singleton("debug_root")
onready var dialog = get_singleton("dialog_viewer")
onready var guns_overlay = get_singleton("guns_root")
onready var stats_overlay = get_singleton("stats_root")
onready var music = get_singleton("music")

var game_time = 0
var game_physics_time = 0

var game_state = {}
var data_tables
var debug_tools_enabled

var current_menu_name = null
func load_menu(name):
	clear_menu(true)
	current_menu_name = name
	G.get_singleton("menu_root").add_child(load("res://menus/%s.tscn" % name).instance())
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func clear_menu(dont_free_mouse = false):
	clear_children(menu_root)
	current_menu_name = null
	if not dont_free_mouse and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var pause_count = 0
func request_pause():
	pause_count += 1
	G.game_root.get_tree().paused = true

func request_unpause():
	if pause_count >= 1:
		pause_count -= 1
	if pause_count <= 0:
		pause_count = 0
		G.game_root.get_tree().paused = false

var loaded_stages = {}
func load_first_stage(name, save_point_id = null, menu_to_show = null):
	pause_count = 0
	G.game_root.get_tree().paused = false

	if menu_to_show:
		load_menu(menu_to_show)
	else:
		clear_menu()
	for stage in loaded_stages.values():
		stage.queue_free()
	loaded_stages = {}
	clear_children(guns_overlay)
	clear_children(common_root)
	clear_children(game_root)
	loaded_stages[name] = load("res://stages/%s.tscn" % name).instance()
	game_root.add_child(loaded_stages[name])
	var found_spawn = false
	if save_point_id:
		for save_point in get_tree().get_nodes_in_group("save_point"):
			if save_point.save_point_id == save_point_id:
				for spawn_point in get_tree().get_nodes_in_group("spawn_point"):
					if save_point.is_a_parent_of(spawn_point):
						found_spawn = true
						spawn(spawn_point)
	if not found_spawn:
		spawn_at_default()

# add stage is done async for thread safety reasons, so we provide a cb when we're done
func add_stage(name, stage_node, cb = null):
	G.call_deferred("add_stage_async", name, stage_node, cb)

func add_stage_async(name, stage_node, cb = null):
	loaded_stages[name] = stage_node
	game_root.add_child(stage_node)
	if cb and cb.is_valid():
		cb.call_func(stage_node)

func remove_stage(name):
	if loaded_stages.has(name):
		var stage = loaded_stages[name]
		stage.get_parent().remove_child(stage)
		stage.queue_free()
		loaded_stages.erase(name)

func get_current_stages_volumes():
	var current_volumes = []
	for sv in get_tree().get_nodes_in_group("stage_volume"):
		for body in sv.get_overlapping_bodies():
			if body.is_in_group("player"):
				current_volumes.append(sv)
	return current_volumes

func get_node_stage(node):
	return loaded_stages[get_node_stage_name(node)]

func get_parent_in_group(node, group):
	if node == null: return null
	var parent = node.get_parent()
	if parent == null: return null
	if parent.is_in_group(group):
		return parent

func get_node_stage_name(node):
	if node == null: return null
	var parent = node.get_parent()
	if parent == null: return null
	if parent == game_root:
		for stage_name in loaded_stages.keys():
			if loaded_stages[stage_name] == node:
				return stage_name
	return get_node_stage_name(parent)

func get_stage_volume(name):
	for stage_volume in get_tree().get_nodes_in_group("stage_volume"):
		var stage_name = get_node_stage_name(stage_volume)
		if stage_name == name:
			return stage_volume

func get_current_stages_names():
	var current_stage_names = []
	for volume in get_current_stages_volumes():
		current_stage_names.append(get_node_stage_name(volume))
	return current_stage_names

func new_game():
	build_initial_game_state()
	load_first_stage("plateau/plateau_stage")

func spawn(point):
	if point:
		var current_player = player()
		if !current_player:
			current_player = preload("res://player/player.tscn").instance()
			common_root.add_child(current_player)
		current_player.take_health("full_heal")
		current_player.global_transform = point.global_transform

func spawn_at_default():
	# get the first default spawn (if possible)
	spawn(get_singleton("default_spawn"))

func clear_children(node):
	for child in node.get_children():
		child.get_parent().remove_child(child)
		child.queue_free()

func get_singleton(name, idx = 0):
	var singleton = get_tree().get_nodes_in_group(name)
	if len(singleton) > idx:
		return singleton[idx]
	else:
		return null

func player(): return get_singleton("player")
func player_pos(): return player().global_transform.origin
func player_loaded(): return true if get_singleton("player") != null else false
func camera(): return .get_viewport().get_camera()

func load_main_menu():
	load_first_stage("main_menu_stage", null, "main_menu")

func at_height(point, height = 0):
	return swizzle("x_z", point) + Vector3(0, height, 0)

func looking_at_height(t: Transform):
	return t.looking_at(at_height(t.origin -  t.basis.z, t.origin.y), Vector3.UP)

func swizzle(selector, pos):
	if selector.length() == 1:
		match selector[0]:
			"x": return pos.x
			"y": return pos.y
			"z": return pos.z
			"_": return 0
	if selector.length() == 2:
		return Vector2( \
			swizzle(selector[0], pos), \
			swizzle(selector[1], pos))
	if selector.length() == 3:
		return Vector3( \
			swizzle(selector[0], pos), \
			swizzle(selector[1], pos), \
			swizzle(selector[2], pos))

func wrap_angle(angle):
	while angle > TAU:
		angle -= TAU
	while angle < 0:
		angle += TAU
	return angle

func quat_axis(quat): return Vector3(quat.x, quat.y, quat.z)

func vec_rad2deg(inp): return Vector3(rad2deg(inp.x), rad2deg(inp.y), rad2deg(inp.z))

func safe_add_child(parent, child):
	if child.get_parent():
		child.get_parent().remove_child(child)
	parent.add_child(child)


func set_alpha_mesh(mesh: Mesh, percent):
	percent = clamp(percent, 0, 1)
	for i in mesh.get_surface_count():
		var mat = mesh.surface_get_material(i)
		mat.flags_transparent = true
		mat.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_ALWAYS
		if mat and mat is SpatialMaterial:
			mat.albedo_color = Color( \
				mat.albedo_color.r,   \
				mat.albedo_color.g,   \
				mat.albedo_color.b,   \
				percent
			)
			mesh.surface_set_material(i, mat)
	
func set_alpha(mesh: MeshInstance, percent):
	percent = clamp(percent, 0, 1)
	for i in mesh.get_surface_material_count():
		var mat = mesh.get_surface_material(i)
		mat.flags_transparent = true
		mat.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_ALWAYS
		if mat and mat is SpatialMaterial:
			mat.albedo_color = Color( \
				mat.albedo_color.r,   \
				mat.albedo_color.g,   \
				mat.albedo_color.b,   \
				percent
			)
			mesh.set_surface_material(i, mat)

func set_color(mesh: MeshInstance, color: Color):
	for i in mesh.get_surface_material_count():
		var mat = mesh.get_surface_material(i)
		mat.flags_transparent = true
		mat.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_ALWAYS
		if mat and mat is SpatialMaterial:
			mat.albedo_color = color
			mesh.set_surface_material(i, mat)

func get_alpha_mesh(mesh: Mesh):
	if mesh.get_surface_count() == 0:
		return 0
	return mesh.surface_get_material(0).albedo_color.a

func get_alpha(mesh: MeshInstance):
	if mesh.get_surface_material_count() == 0:
		return 0
	return mesh.get_surface_material(0).albedo_color.a
	
func get_color(mesh: MeshInstance):
	if mesh.get_surface_material_count() == 0:
		return Color.white
	return mesh.get_surface_material(0).albedo_color

func level_towards_player(owner):
	return -(G.swizzle("x_z", owner.global_transform.origin - G.player_pos())).normalized()

func random_color():
	randomize()
	return Color(randf(), randf(), randf())

func raycast_cansee(looker, lookee, eye_level):
	var looker_eye_level = Vector3.ZERO
	var lookee_eye_level = Vector3.ZERO
	if eye_level:
		match typeof(eye_level):
			TYPE_ARRAY:
				match len(eye_level):
					1:
						looker_eye_level = Vector3(0, eye_level[0], 0)
					2:
						looker_eye_level = Vector3(0, eye_level[0], 0)
						lookee_eye_level = Vector3(0, eye_level[1], 0)
			_:
				looker_eye_level = Vector3(0, eye_level, 0)
				lookee_eye_level = Vector3(0, eye_level, 0)

	var res = raycast(
		looker.global_transform.origin + looker_eye_level,
		lookee.global_transform.origin + lookee_eye_level,
		[looker])
	return res and res.collider == lookee

func raycast_forward(start, ignore_list = [], collision_mask = []):
	return raycast(start, start.basis.z, ignore_list, collision_mask)

func raycast_rel(start, end, ignore_list = [], collision_mask = []):
	return raycast(start, start + end, ignore_list, collision_mask)

func raycast(start, end, ignore_list = [], collision_mask = []):
	var space_state = get_tree().root.get_world().get_direct_space_state()
	return space_state.intersect_ray(start, end, ignore_list, mask_layers(collision_mask))

func dist_to_player(this_self):
	return this_self.global_transform.origin.distance_to(player_pos())

func to_unique_materials_mesh(mesh: Mesh):
	for i in mesh.get_surface_count():
		var mat = mesh.surface_get_material(i)
		if mat:
			mesh.surface_set_material(i, mat.duplicate())

func to_unique_materials(mesh: MeshInstance):
	for i in mesh.get_surface_material_count():
		var mat = mesh.get_surface_material(i)
		if mat:
			mesh.set_surface_material(i, mat.duplicate())

func build_initial_game_state(data = null):
	if not data: data = {}
	game_state = data.game_state if data.has("game_state") else {}
	if not game_state.has("stats"):
		game_state.stats = {
			health = 100,
			tanks = 0,
			max_tanks = 0,
			artifacts = 0,
			guns = [ "scanner" ],
			color_gun_colors = [],
			active_color_gun_color = "",
			active_gun = "",
			actions = [ ],
			active_action = "",
			abilities = [ "jump" ],
			lore_entries = [ ],
		}
	if not game_state.has("elevators"):
		G.game_state.elevators = {}
	if not game_state.has("pickups"):
		G.game_state.pickups = {}
	if not game_state.has("gates"):
		G.game_state.gates = {}
	if not game_state.has("stage_state"):
		G.game_state.stage_state = {}
	
	if not game_state.has("show_debug_overlay"):
		game_state.show_debug_overlay = false

func step_towards(current, target, velo):
	if current > target:
		current -= velo
		if current < target:
			return target
		else:
			return current
	if current < target:
		current += velo
		if current > target:
			return target
		else:
			return current
	if current == target:
		return current

func is_collider_pressed(targets = null, distance = 3):
	var pressed = Input.is_action_just_pressed("use")
	if not pressed: return false
	if not G.player(): return false
	if G.player().freeze_input: return false

	# if we weren't given a target, distance doesn't matter. Success
	if targets == null:
		return true
	
	# the player isn't looking at anything, but the user wanted to know if we could see something specific
	if not G.player().looking_at: return false
	
	# if its too far away, it doesn't matter if we're looking at the right thing
	if G.player().looking_at.distance_to > distance: return false

	# see if we're looking at any of our targets
	# targets may be one target or a list of targets, covert to an array if only one
	targets = targets if typeof(targets) == TYPE_ARRAY else [targets]
	for target in targets:
		if target == G.player().looking_at.collider:
			return pressed
	return false
	

# wrapper around tween.interpolate_property that automatically creates a tween node, starts it, and waits for it to finish
func tween_property(object, property, initial_val, final_val, duration, trans_type = 0, ease_type = 2, delay = 0):
	var tween = Tween.new()
	G.utils_root.add_child(tween)
	tween.interpolate_property(object, property, initial_val, final_val, duration, trans_type, ease_type, delay)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()

func get_scan_tag(node):
	if node.is_in_group("scannable"):
		for child in node.get_children():
			if child.is_in_group("scan_tag"):
				return child.tag
	return null

func can_be_scanned(node):
	var scan_tag = get_scan_tag(node)
	if scan_tag:
		return true

func map_range(value, input_low, input_high, output_low, output_high):
	var f_value = float(value)
	var f_input_low = float(input_low)
	var f_input_high = float(input_high)
	var f_output_low = float(output_low)
	var f_output_high = float(output_high)
	return(f_value - f_input_low) / (f_input_high - f_input_low) * (f_output_high - f_output_low) + f_output_low


func wrapped_lerp(first, second, weight, wrap):
	if second > first:
		return lerp(first, second, weight)
	else:
		var c_range: float = wrap - first + second
		var lerped: float = lerp(0, c_range, weight)
		var wrapped = fmod(lerped + first, wrap)
		return wrapped

func v3(x): return Vector3(x, x, x)

func mask_layers(layers):
	var total = 0
	for i in layers:
		total += pow(2, i - 1)
	if total == 0: return 0x7FFFFFFF
	return total

func get_parent_nav(node):
	if node == null or node.get_parent() == null:
		return null
	elif node.get_parent() is Navigation:
		return node.get_parent()
	else:
		return get_parent_nav(node.get_parent())
