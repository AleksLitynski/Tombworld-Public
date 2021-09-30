extends Spatial

export(String) var item_name = "t_gun" # G.data_tables.selectable_textures.keys()
export(String) var on_collect_dialog = ""

signal on_pickup

func _ready():
	$MeshInstance.mesh = $MeshInstance.mesh.duplicate()
	G.to_unique_materials($MeshInstance)
	G.to_unique_materials_mesh($MeshInstance.mesh)
	if not G.game_state.pickups.has(str(get_path())):
		G.game_state.pickups[str(get_path())] = item_name
	else:
		item_name = G.game_state.pickups[str(get_path())]

func _process(delta):
	$MeshInstance.visible = item_name != ""

	$text_3d.visible = item_name != ""
	if item_name != "":
		var mat = $MeshInstance.mesh.surface_get_material(0)
		mat.albedo_texture = G.data_tables.selectable_textures[item_name]
		$MeshInstance.mesh.surface_set_material(0, mat)
	

	$MeshInstance.transform.origin.y += sin(G.game_time * 2) * 0.004
	$MeshInstance.transform.basis = $MeshInstance.transform.basis.rotated( \
		Vector3.UP, \
		0.5 * delta)

	if G.is_collider_pressed($StaticBody):
		if item_name == "health":
			G.player().take_health("full_heal")
			G.game_state.stats.tanks += 1
			G.game_state.stats.max_tanks += 1
		elif item_name == "artifact":
			G.game_state.stats.artifacts += 1
		elif item_name in G.data_tables.weapon_tscns.keys():
			G.game_state.stats.guns.append(item_name)
		elif item_name in G.data_tables.action_tscns.keys():
			G.game_state.stats.actions.append(item_name)
		elif item_name in G.data_tables.four_color_gun_colors.keys():
			G.game_state.stats.color_gun_colors.append(G.data_tables.four_color_gun_colors[item_name])
			if G.game_state.stats.active_color_gun_color == "":
				G.game_state.stats.active_color_gun_color = G.data_tables.four_color_gun_colors[item_name]
		else:
			G.game_state.stats.abilities.append(item_name)
		item_name = ""
		emit_signal("on_pickup")

		if on_collect_dialog != null and on_collect_dialog != "":
			G.dialog.show_dialog_and_save(on_collect_dialog)

	G.game_state.pickups[str(get_path())] = item_name
