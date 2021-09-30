extends Spatial

var current_gun = ""
func _process(delta):
	var gun = next_gun()
	if gun != current_gun:
		if gun != "":
			var mat = $MeshInstance.mesh.surface_get_material(0)
			mat.albedo_texture = G.data_tables.selectable_textures[gun]
			$MeshInstance.mesh.surface_set_material(0, mat)
		current_gun = gun
	
	if current_gun != "" and G.game_state.stats.artifacts >= G.data_tables.gun_prices[gun]:
		$text_3d.text = "[E to buy]"
		$MeshInstance.visible = true
		$AnimatedSprite3D.visible = false
		if G.is_collider_pressed($vendo/vendo/static_collision):
			if gun in G.data_tables.weapon_tscns.keys():
				G.game_state.stats.guns.append(gun)
				if G.data_tables.gun_dialogs.has(gun):
					G.dialog.show_dialog_and_save(G.data_tables.gun_dialogs[gun])
			else:
				if not "four_color" in G.game_state.stats.guns:
					G.game_state.stats.guns.append("four_color")
					G.dialog.show_dialog_and_save(G.data_tables.gun_dialogs["four_color"])
					G.game_state.stats.active_color_gun_color = G.data_tables.four_color_gun_colors[gun]
				G.game_state.stats.color_gun_colors.append(G.data_tables.four_color_gun_colors[gun])
			G.game_state.stats.artifacts -= G.data_tables.gun_prices[gun]
	else:
		if gun == "":
			$text_3d.text = "[No more guns]"
		else:
			$text_3d.text = "[Next item %s artifacts]" % G.data_tables.gun_prices[gun]
		$MeshInstance.visible = false
		$AnimatedSprite3D.visible = true

	$MeshInstance.transform.origin.y += sin(G.game_time * 2) * 0.002
	$AnimatedSprite3D.transform.origin.y += sin(G.game_time * 2) * 0.002


func _ready():
	$AnimatedSprite3D.frames.set_animation_speed("default", 3)

func next_gun():
	for gun in G.data_tables.gun_unlock_order:
		var c_gun_name = "__fake_name__"
		if not gun in G.data_tables.weapon_tscns.keys():
			c_gun_name = G.data_tables.four_color_gun_colors[gun]
		if not gun in G.game_state.stats.guns and not c_gun_name in G.game_state.stats.color_gun_colors:
			return gun
	return ""
