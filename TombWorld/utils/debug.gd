extends Control

func _ready():
	visible = false
	$show_debug.connect("pressed", self, "toggle_visible")
	$noclip.connect("pressed", self, "toggle_no_clip")
	$show_debug.pressed = visible

var persisted_data = {}
var persisted_lines = {}

func make_value_node(key, value):
	var root = HBoxContainer.new()
	var key_label = Label.new()
	key_label.name = "key"
	var value_label = Label.new()
	value_label.name = "value"
	key_label.text = key
	value_label.text = value
	root.add_child(key_label)
	root.add_child(value_label)
	return root

func set_data_round(key, value): return show_data_round(key, value)
func show_data_round(key, value, places = 1):
	show_data(key, stepify(value, pow(0.1, places)))

func data(key, value): return show_data(key, value)
func set_data(key, value): return show_data(key, value)
func show_data(key, value):
	if persisted_data.has(key):
		var value_node = persisted_data[key]
		value_node.get_node("value").text = String(value if value != null else "null")
	else:
		persisted_data[key] = make_value_node(key, String(value if value != null else "null"))
		$HBoxContainer/Persists/items.add_child(persisted_data[key])

func hide_data(key):
	if persisted_data.has(key):
		persisted_data[key].queue_free()
		persisted_data.erase(key)

func log(value): return log_data(value)
func log_data(value):
	var line = Label.new()
	line.text = str(value)
	$HBoxContainer/Logs/items.add_child(line)
	$HBoxContainer/Logs.scroll_vertical = $HBoxContainer/Logs/items.rect_size.y

func _input(event):
	if G.debug_tools_enabled and event.is_action_pressed("toggle_debug"):
		toggle_visible()

func toggle_visible():
	visible = !visible
	$show_debug.pressed = visible
	G.game_state.show_debug_overlay = visible

func hide_debug():
	visible = false
	$show_debug.pressed = visible
	G.game_state.show_debug_overlay = visible

func toggle_no_clip():
	var player = G.player()
	if player:
		player.no_clip = !player.no_clip
		$noclip.pressed = player.no_clip

func get_dev_config():
	var config = load("res://dev_config.gd")
	if !config:
		return load("res://default_dev_config.gd").new()
	return config.new()

func line_rel(name, start, end, opts = {}): return show_line_relative(name, start, end, opts)
func show_line_relative(name, start, end, opts = {}):
	return show_line(name, start, start + end, opts)

func line(name, start, end, opts = {}): return show_line(name, start, end, opts)
func show_line(name, start, end, opts = {}):
	if persisted_lines.has(name):
		persisted_lines[name].start = start
		persisted_lines[name].end = end
		persisted_lines[name].opts = opts
	else:
		persisted_lines[name] = {
			geom = ImmediateGeometry.new(),
			start = start,
			end = end,
			opts = opts,
		}
		add_child(persisted_lines[name].geom)
		var mat = SpatialMaterial.new()
		mat.vertex_color_use_as_albedo = true
		mat.vertex_color_is_srgb = true
		mat.flags_unshaded = true
		persisted_lines[name].geom.set_material_override(mat)
		
	if !persisted_lines[name].opts.has("color"):
		persisted_lines[name].opts.color = Color.red
	if !persisted_lines[name].opts.has("y_value"):
		persisted_lines[name].opts.y_value = 3
	if persisted_lines[name].start is Vector2:
		persisted_lines[name].start = G.swizzle("x_y", persisted_lines[name].start) + Vector3(0, persisted_lines[name].opts.y_value, 0)
	if persisted_lines[name].end is Vector2:
		persisted_lines[name].end = G.swizzle("x_y", persisted_lines[name].end) + Vector3(0, persisted_lines[name].opts.y_value, 0)

func hide_line(name):
	if persisted_lines.has(name):
		persisted_lines[name].geom.queue_free()
		persisted_lines.erase(name)

func _process(delta):
	var player = G.player()
	if player: $noclip.pressed = player.no_clip
	if G.debug_tools_enabled and Input.is_action_just_pressed("toggle_noclip"):
		toggle_no_clip()
	for line in persisted_lines.values():
		line.geom.clear()
		if $show_debug.pressed:
			line.geom.begin(PrimitiveMesh.PRIMITIVE_LINES)
			line.geom.set_color(line.opts.color)
			line.geom.add_vertex(line.start)
			line.geom.add_vertex(line.end)
			line.geom.end()
	
	if G.game_state.has("show_debug_overlay") and G.game_state.show_debug_overlay != visible:
		toggle_visible()
	
	if not G.debug_tools_enabled:
		hide_debug()
