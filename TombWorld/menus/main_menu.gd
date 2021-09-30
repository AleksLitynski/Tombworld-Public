extends Control

func _on_start_pressed():
	G.load_menu("load_menu")


func _on_quit_pressed():
	get_tree().quit()


func _on_GotoCredits_pressed():
	G.load_menu("credits_menu")
