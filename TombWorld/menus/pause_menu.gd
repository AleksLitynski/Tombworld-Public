extends Control

func _on_Continue_pressed():
	G.clear_menu()
	G.request_unpause()

func _on_QuitGame_pressed():
	get_tree().quit()

func _on_GotoMainMenu_pressed():
	G.load_main_menu()

func _on_ReloadQuicksave_pressed():
	# unimplemented. Same as reload save for now
	G.saves.reload_current_slot()

func _on_ReloadSave_pressed():
	G.saves.reload_current_slot()


var guns = []
var actions = []
var logs = []
func _process(delta):
	ListRectifier.rectify_lists(
		guns, G.game_state.stats.guns, $HBoxContainer/logs/VBoxContainer/Guns/gun_list,
		preload("res://ui/stats/selectable.tscn"), funcref(self, "_setup_item"))
	ListRectifier.rectify_lists(
		actions, G.game_state.stats.actions, $HBoxContainer/logs/VBoxContainer/Actions/action_list,
		preload("res://ui/stats/selectable.tscn"), funcref(self, "_setup_item"))

	$HBoxContainer/logs/VBoxContainer/Guns.visible = guns.size() != 0
	$HBoxContainer/logs/VBoxContainer/Actions.visible = actions.size() != 0

	$HBoxContainer/logs/VBoxContainer/Stats/Tanks.text = "Tanks: %s" % G.game_state.stats.max_tanks
	$HBoxContainer/logs/VBoxContainer/Stats/Artifacts.text = "Artifacts: %s" % G.game_state.stats.artifacts

	ListRectifier.rectify_lists(
		logs, G.game_state.stats.lore_entries, $HBoxContainer/logs/VBoxContainer/LogList/logs,
		preload("res://ui/lore_label.tscn"), funcref(self, "_populate_log"))

func _setup_item(node, item, root):
	node.get_node("Label").visible = false
	node.get_node("AnimationPlayer").queue_free()
	node.remove_child(node.get_node("AnimationPlayer"))
	node.get_node("ColorRect").modulate.a = 1
	node.get_node("ColorRect").rect_min_size = Vector2(50, 50)
	node.get_node("ColorRect").rect_size = Vector2(50, 50)
	node.get_node("ColorRect/MarginContainer/TextureButton").texture_disabled = G.data_tables.selectable_textures[item]

func _populate_log(node, item, root):
	node.get_node("Button").text = item

