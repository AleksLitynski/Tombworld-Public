extends Node2D

signal trigger_pressed
signal trigger_released

var current_gun
var current_gun_name = ""
var can_fire = false
var swapping_guns = false
var trigger_down = false
var last_weapon_scroll_time = 0
var scrolling_weapons = false

func _ready():
	can_fire = false
	goto_gun(_current_gun_idx())

func goto_gun(idx = null):
	if not swapping_guns:
		if idx == null or G.game_state.stats.guns.size() == 0:
			G.game_state.stats.active_gun = ""
		else:
			idx = idx % G.game_state.stats.guns.size()
			G.game_state.stats.active_gun = G.game_state.stats.guns[idx]

func _current_gun_idx():
	var idx = G.game_state.stats.guns.find(G.game_state.stats.active_gun)
	if idx == -1: return null
	return idx

func _holster_gun():
	if current_gun:
		var g_size = current_gun.get_bounds()
		var g_pos = current_gun.get_position()
		yield(G.tween_property(current_gun, "position", g_pos, Vector2(g_pos.x, g_pos.y + g_size.y), .35, Tween.TRANS_LINEAR), "completed")
		current_gun.queue_free()
		current_gun = null
	else:
		# even if there's no gun, we still need to yield _something_, so just wait a frame and continue
		yield(get_tree(), "idle_frame")

func _draw_gun(to_draw):
	current_gun = to_draw
	var g_size = current_gun.get_bounds()
	var g_pos = current_gun.get_position()
	current_gun.position = Vector2(-g_size.x, g_pos.y)
	G.guns_overlay.add_child(current_gun)
	yield(G.tween_property(current_gun, "position", Vector2(-g_size.x, g_pos.y), g_pos, .3, Tween.TRANS_LINEAR), "completed")
	current_gun.fix_position()

func _input(ev):
	if G.player().freeze_input: return
	if Input.is_action_pressed("action_select_mode"): return
	if ev.is_action_pressed("weapon_1"): goto_gun(0)
	if ev.is_action_pressed("weapon_2"): goto_gun(1)
	if ev.is_action_pressed("weapon_3"): goto_gun(2)
	if ev.is_action_pressed("weapon_4"): goto_gun(3)
	if ev.is_action_pressed("weapon_5"): goto_gun(4)
	if G.game_time > last_weapon_scroll_time + 0.1 or (not scrolling_weapons):
		if ev.is_action_pressed("next_weapon"):
			last_weapon_scroll_time = G.game_time
			scrolling_weapons = true
			goto_gun((_current_gun_idx() - 1) if _current_gun_idx() != null else 0)
		if ev.is_action_pressed("previous_weapon"):
			last_weapon_scroll_time = G.game_time
			scrolling_weapons = true
			goto_gun((_current_gun_idx() + 1) if _current_gun_idx() != null else 0)
	if ev.is_action_pressed("fire"):
		if not _current_gun_idx() and G.game_state.stats.guns.size() > 0:
			goto_gun(0)


func _process(delta):
	
	if (G.game_time > last_weapon_scroll_time + 0.4 and scrolling_weapons) or trigger_down:
		scrolling_weapons = false
	
	# track the trigger state
	var new_trigger_down = Input.is_action_pressed("fire") and can_fire and not G.player().freeze_input
	if new_trigger_down != trigger_down:
		if new_trigger_down:
			emit_signal("trigger_pressed")
		else:
			emit_signal("trigger_released")
	trigger_down = new_trigger_down
	
	# rectify the current gun with the selected gun
	if G.game_state.stats.active_gun != current_gun_name and not swapping_guns and not scrolling_weapons:
		swapping_guns = true
		can_fire = false
		emit_signal("trigger_released")
		current_gun_name = G.game_state.stats.active_gun
		# 1. holster our current gun
		yield(_holster_gun(), "completed")
		# 2. draw our new gun
		if current_gun_name != "":
			yield(_draw_gun(G.data_tables.weapon_tscns[current_gun_name].instance()), "completed")
		# 3. all done :)
		can_fire = true
		swapping_guns = false
		if trigger_down:
			emit_signal("trigger_pressed")
