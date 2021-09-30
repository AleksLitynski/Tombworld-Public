extends Spatial

export(String) var save_point_id = "<MUST BE UNIQUE PER STAGE>"

func _input(inp):
	if G.is_collider_pressed($StaticBody):
			G.saves.save()
			G.player().take_health("full_heal")
			yield(get_tree().create_timer(0.1), "timeout")
			G.dialog.show_dialog("""
				[Ship] Save Successful
			""")

