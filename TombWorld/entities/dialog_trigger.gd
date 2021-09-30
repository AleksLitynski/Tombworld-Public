extends Area


export(String) var message = ""

func _on_text_trigger_body_entered(body):
	if body.is_in_group("player") and not message in G.game_state.stats.lore_entries:
		G.dialog.show_dialog_and_save(message)
