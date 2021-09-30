extends Control

onready var tank_tscn = preload("res://ui/stats/tank.tscn")
onready var selectable_tscn = preload("res://ui/stats/selectable.tscn")
onready var health = $health/MarginContainer/VBoxContainer/health/ProgressBar
onready var tanks = $health/MarginContainer/VBoxContainer/tanks/tanks
onready var artifacts = $collectables/VBoxContainer/artifacts/VBoxContainer/Label
onready var action_list = $selectables/HBoxContainer/actions/action_list
onready var gun_list = $selectables/HBoxContainer/guns/gun_list

var guns = []
var actions = []
var active_gun = ""
var active_action = ""

var target_health = 100
var swap_speed = 5

var dash_restored_time = -1000

func _process(delta):
	# if there are not stats to show, hide ourself and exit
	if not G.game_state.has("stats"):
		visible = false
		return
	visible = true
	var stats = G.game_state.stats

#	# set health
#	if stats.health > target_health:
#		health.value = stats.health
#	else:
	target_health = stats.health
	if target_health > health.value:
		health.value = G.step_towards(health.value, target_health, delta * 500)
	else:
		health.value = G.step_towards(health.value, target_health, delta * 100)

	# add/remove tanks to match expected tanks
	while tanks.get_children().size() > stats.max_tanks:
		tanks.remove_child(tanks.get_children()[0])
	while tanks.get_children().size() < stats.max_tanks:
		tanks.add_child(tank_tscn.instance())

	# activate/deactivate tanks to match available tanks
	var tank_idx = 0
	for tank in tanks.get_children():
		if tank_idx < stats.tanks:
			tank.value = 1
		else:
			tank.value = 0
		tank_idx += 1

	artifacts.text = str(stats.artifacts)

	ListRectifier.rectify_lists(
		guns, stats.guns, gun_list, 
		preload("res://ui/stats/selectable.tscn"), funcref(self, "_setup_item"),
		stats.active_gun, funcref(self, "_activate_item"), funcref(self, "_deactivate_item"))
	ListRectifier.rectify_lists(
		actions, stats.actions, action_list,
		preload("res://ui/stats/selectable.tscn"), funcref(self, "_setup_item"), 
		stats.active_action, funcref(self, "_activate_item"), funcref(self, "_deactivate_item"))
	
	if G.player() and G.player().looking_at:
		var is_enemy = G.player().looking_at.collider.is_in_group("enemy")
		var is_scannable = G.can_be_scanned(G.player().looking_at.collider)
		if is_enemy and is_scannable:
			if not G.get_scan_tag(G.player().looking_at.collider) in G.game_state.stats.lore_entries:
				$crosshairs.modulate = Color.purple
			else:
				$crosshairs.modulate = Color.red
		elif is_enemy:
			$crosshairs.modulate = Color.red
		elif is_scannable:
			$crosshairs.modulate = Color.blue
		else:
			$crosshairs.modulate = Color.black
	else:
		$crosshairs.modulate = Color.black
		
	if G.player() and "dash" in G.game_state.stats.abilities:
		$collectables/VBoxContainer/dash_charges.visible = true
		if G.player().dash.charges > 0 and not G.player().dash.active:
			if $collectables/VBoxContainer/dash_charges.texture == preload("res://assets/icons/ui_dash_empty.png"):
				dash_restored_time = G.game_time
			if G.game_time < dash_restored_time + 0.4:
				$collectables/VBoxContainer/dash_charges.texture = preload("res://assets/icons/ui_dash_restored.png")
			else:
				$collectables/VBoxContainer/dash_charges.texture = preload("res://assets/icons/ui_dash_ready.png")
		else:
			$collectables/VBoxContainer/dash_charges.texture = preload("res://assets/icons/ui_dash_empty.png")
	else:
		$collectables/VBoxContainer/dash_charges.visible = false
		
	
func _setup_item(node, item, root):
	node.get_node("Label").text = str(node.get_index() + 1)
	node.get_node("AnimationPlayer").current_animation = "active"
	node.get_node("ColorRect/MarginContainer/TextureButton").texture_disabled = G.data_tables.selectable_textures[item]

func _activate_item(node, item, root):
	var p: AnimationPlayer = node.get_node("AnimationPlayer")
	# plat forwards to end
	if p.current_animation_position > 0.1:
		p.play("active", -1, -swap_speed, false)
	else:
		p.stop(false)

func _deactivate_item(node, item, root):
	var p: AnimationPlayer = node.get_node("AnimationPlayer")
	# play backwards to end
	if p.current_animation_position < p.current_animation_length - 0.1:
		p.play("active", -1, swap_speed, false)
	else:
		p.stop(false)
