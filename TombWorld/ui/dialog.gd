extends Control


func _ready():
	hide_dialog(true)

func showing_dialog():
	return target_modulate != 0

func _parse_dialog(dialog_str):
	var dialog_lines = []
	for line in dialog_str.split("\n"):
		line = line.strip_edges(true, true)
		if line.find("[") == 0:
			var speaker_end = line.find("]")
			dialog_lines.push_back({
				speaker = line.substr(1, speaker_end - 1),
				message = line.substr(speaker_end + 1).strip_edges(true, true),
			})
		elif dialog_lines.size() > 0:
				dialog_lines[dialog_lines.size() - 1].message += "\n" + line.strip_edges(true, true)
	return dialog_lines

var idx = 0
var target_offset = 0
var target_modulate = 1
func show_dialog(dialog_str):
	clear_messages()
	var dialog = _parse_dialog(dialog_str)
	for line in dialog:
		var msg = preload("res://ui/message.tscn").instance()
		msg.speaker = line.speaker
		msg.message = line.message
		msg.icon = load(G.data_tables.dialog_icons[line.speaker])
		msg.flipped = msg.speaker != "Lario"
		$scroll/messages.add_child(msg)

	yield(get_tree(), "idle_frame")
	target_modulate = 1
	$Label.text = "[SPACE to continue]"
	_show_next(true)

	G.request_pause()
	G.menu_root.pause_mode = Node.PAUSE_MODE_STOP
	mouse_filter = Control.MOUSE_FILTER_STOP

func show_named_dialog(dialog_name):
	if G.data_tables.dialogs.has(dialog_name):
		show_dialog(G.data_tables.dialogs[dialog_name])

func show_dialog_and_save(name):
	show_named_dialog(name)
	if not name in G.game_state.stats.lore_entries:
		G.game_state.stats.lore_entries.push_front(name)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_show_next()

func clear_messages():
	$scroll/messages.rect_position.y = 0
	$scroll/messages.rect_size.y = 0
	idx = 0
	target_offset = 0
	for child in $scroll/messages.get_children():
		$scroll/messages.remove_child(child)
		child.queue_free()

func hide_dialog(force = false):
	if force: modulate.a = 0
	target_modulate = 0
	if mouse_filter != Control.MOUSE_FILTER_IGNORE:
		G.menu_root.pause_mode = Node.PAUSE_MODE_PROCESS
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		G.request_unpause()

func _show_next(force = false):
	idx += 1
	
	if idx > $scroll/messages.get_child_count():
		hide_dialog()
		yield(get_tree(), "idle_frame")
		return
	elif idx == $scroll/messages.get_child_count():
		target_offset = $scroll.rect_size.y - $scroll/messages.rect_size.y
		$Label.text = "[SPACE to exit]"
	else:
		target_offset = $scroll.rect_size.y - $scroll/messages.get_child(idx).rect_position.y

	if force:
		$scroll/messages.rect_position.y = target_offset

func _process(delta):
	if $scroll/messages.get_child_count() > 0 and target_offset != $scroll/messages.rect_position.y:
		if abs(target_offset - $scroll/messages.rect_position.y) > 1:
			$scroll/messages.rect_position.y = lerp($scroll/messages.rect_position.y, target_offset, delta * 14)
		else:
			$scroll/messages.rect_position.y = target_offset

	if target_modulate != modulate.a:
		if abs(modulate.a - target_modulate) > 0.1:
			modulate.a = lerp(modulate.a, target_modulate, delta * 5)
		else:
			modulate.a = target_modulate
			if target_modulate == 0:
				clear_messages()
