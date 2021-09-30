extends MarginContainer


func _on_Button_pressed():
	$Button.release_focus()
	if not G.dialog.showing_dialog():
		G.dialog.show_named_dialog($Button.text)
