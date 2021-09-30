extends Node

var current_save_slot = "slot_1_save"
func list_saves():
	var files = []
	ensure_save_dir()
	var save_dir = Directory.new()
	save_dir.open("user://saves")
	save_dir.list_dir_begin()
	var file = save_dir.get_next()
	while file != "":
		if file != "." and file != "..":
			files.append(file.split(".json")[0])
		file = save_dir.get_next()
	return files

func collect_save_data():
	var save_datas = []
	for to_save in G.get_tree().get_nodes_in_group("saveable"):
		save_datas.append({
			id = to_save.save_id,
			deps = to_save.save_deps,
			data = to_save.get_save_data()
		})
	return save_datas

func apply_save_data(saved_nodes):
	# Data is an array in the form [{id, deps, data}]
	# Id is a unique id. deps is an array of unique ids that must be loaded before us
	# data is the data this node needs to load
	# So, we loop through and load all the saved nodes that have no deps
	# As we loop, we keep a list of deps we have loaded
	# After looping, we:
	# 	delete the saved_nodes items that were loaded
	# 	remove those items from the deps of all other saved nodes
	# Obv, this isn't super efficient, but I expect we'll have ~10 nodes max
	var newly_loaded = []
	var save_idx = -1
	for saved_node in saved_nodes:
		save_idx += 1
		# if we're good to go, load us
		if len(saved_node.deps) == 0:
			for to_load in G.get_tree().get_nodes_in_group("saveable"):
				if to_load.save_id == saved_node.id:
					to_load.load_save_data(saved_node.data)
					newly_loaded.append(save_idx)
					break

	# use the 'newly_loaded' ids to clean up saved_nodes
	var prev_len = len(saved_nodes)
	for idx in newly_loaded:
		var id = saved_nodes[idx].id
		saved_nodes.remove(idx)
		for saved_node in saved_nodes:
			var id_idx = saved_node.deps.find(id)
			if id_idx != -1:
				saved_node.deps.remove(id_idx)

	# Recurse as long as there are move nodes to load
	# to avoid endless loops, if we didn't eliminate any saved nodes, give up,
	# the deps will never resolve
	if len(saved_nodes) > 0 and prev_len != len(saved_nodes):
		apply_save_data(saved_nodes)


func save(save_name = null):
	if !save_name:
		save_name = current_save_slot
	save_name += ".json"

	var save_data = collect_save_data()

	ensure_save_dir()
	var save_file = File.new()
	save_file.open("user://saves/%s" % save_name, File.WRITE)
	save_file.store_line(JSON.print({
		version = 0,
		data = save_data
	}, "    "))
	save_file.close()

func ensure_save_dir():
	var save_dir = Directory.new()
	if !(save_dir.dir_exists("user://saves")):
		save_dir.open("user://")
		save_dir.make_dir("user://saves")

func get_save_data(name):
	ensure_save_dir()
	var save_file = File.new()
	save_file.open("user://saves/%s.json" % name, File.READ)
	var save_data = parse_json(save_file.get_as_text()).data
	save_file.close()
	return save_data

func get_node_by_id(save_data, id):
	for node in save_data:
		if node.id == id:
			return node.data

func load_save(name):
	current_save_slot = name
	apply_save_data(get_save_data(name))

func reload_current_slot():
	load_slot(current_save_slot)

func load_slot(name):
	current_save_slot = name
	if save_exists(name):
		load_save(name)
	else:
		G.new_game()

func save_exists(name):
	var saves = list_saves()
	return saves.find(name) != -1

func get_save_friendly_name(slot):
	var stage_parts = get_node_by_id(get_save_data(slot), "main").stage.split("/")
	return stage_parts[len(stage_parts) - 1].replace("_", " ") \
		.replacen("stage", "") \
		.strip_edges(true, true)
