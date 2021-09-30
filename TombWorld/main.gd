extends Node

func _ready():
	G.data_tables = DataTables.new()
	G.utils_root.add_child(G.data_tables)

	var cfg = G.debug.get_dev_config()
	if cfg.autoload_slot:
		G.saves.load_save(cfg.autoload_slot)
	else:
		G.load_main_menu()
	
	G.debug_tools_enabled = cfg.debug_tools_enabled

	# entities that have particles effects need to prepare their cache at startup
	preload("res://entities/bullets/laser.tscn").instance().prep_cache()
	preload("res://entities/bullets/sneeze.tscn").instance().prep_cache()

	if cfg.limit_8_lights:
		G.utils_root.add_child(LightActivator.new())

	OS.min_window_size = Vector2(1200, 900)


var save_id = "main"
var save_deps = []
func get_save_data():
	var player = G.player()
	return {
		stage = "main_menu_stage" if not player else G.get_current_stages_names()[0],
		menu = G.current_menu_name,
		save_point_id = null if not player else G.get_parent_in_group(player.looking_at.collider, "save_point").save_point_id,
		game_state = G.game_state,
	}

func load_save_data(data):
	G.build_initial_game_state(data)
	G.load_first_stage(data.stage, data.save_point_id)
	if data.menu:
		G.load_menu(data.menu)
	else:
		G.clear_menu()

func _process(delta):
	G.game_time += delta

func _physics_process(delta):
	G.game_physics_time += delta

func _input(ev):
	if ev.is_action_pressed("pause") and G.dialog.target_modulate == 0:
		if not G.current_menu_name:
			G.load_menu("pause_menu")
			G.request_pause()
		elif G.current_menu_name == "pause_menu":
			G.clear_menu()
			G.request_unpause()

