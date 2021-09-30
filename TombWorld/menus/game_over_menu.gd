extends Control

func _ready():
	G.player().freeze_input = true
	modulate.a = 0

func _process(delta):
	modulate.a = G.step_towards(modulate.a, 1, delta * 0.4)

func _on_ReloadQuicksave_pressed():
	# unimplemented. Same as reload save for now
	G.player().freeze_input = false
	G.saves.reload_current_slot()

func _on_ReloadSave_pressed():
	G.player().freeze_input = false
	G.saves.reload_current_slot()

func _on_GotoMainMenu_pressed():
	G.player().freeze_input = false
	G.load_main_menu()

func _on_QuitGame_pressed():
	G.player().freeze_input = false
	get_tree().quit()

