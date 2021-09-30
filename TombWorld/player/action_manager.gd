extends Node2D

signal trigger_pressed
signal trigger_released

var trigger_down = false
var last_scroll_time = 0

var current_action

func _ready():
	goto_action(_current_idx())

func goto_action(idx = null):
	if idx == null or G.game_state.stats.actions.size() == 0:
		G.game_state.stats.active_action = ""
	else:
		idx = idx % G.game_state.stats.actions.size()
		G.game_state.stats.active_action = G.game_state.stats.actions[idx]
	load_action(G.game_state.stats.active_action)

func load_action(name):
	if current_action: current_action.queue_free()
	if name == "": return
	current_action = G.data_tables.action_tscns[name].instance()
	add_child(current_action)

func _current_idx():
	var idx = G.game_state.stats.actions.find(G.game_state.stats.active_action)
	if idx == -1: return null
	return idx

func _input(ev):
	if G.player().freeze_input: return
	if not Input.is_action_pressed("action_select_mode"): return
	if ev.is_action_pressed("weapon_1"): goto_action(0)
	if ev.is_action_pressed("weapon_2"): goto_action(1)
	if ev.is_action_pressed("weapon_3"): goto_action(2)
	if ev.is_action_pressed("weapon_4"): goto_action(3)
	if ev.is_action_pressed("weapon_5"): goto_action(4)
	if G.game_time > last_scroll_time + 0.1:
		if ev.is_action_pressed("next_weapon"):
			last_scroll_time = G.game_time
			goto_action((_current_idx() - 1) if _current_idx() != null else 0)
		if ev.is_action_pressed("previous_weapon"):
			last_scroll_time = G.game_time
			goto_action((_current_idx() + 1) if _current_idx() != null else 0)
	if ev.is_action_pressed("action"):
		if not _current_idx() and G.game_state.stats.guns.size() > 0:
			goto_action(0)

func _process(delta):
	# track the trigger state
	var new_trigger_down = Input.is_action_pressed("action") and not G.player().freeze_input
	if new_trigger_down != trigger_down:
		if new_trigger_down:
			emit_signal("trigger_pressed")
		else:
			emit_signal("trigger_released")
	trigger_down = new_trigger_down
