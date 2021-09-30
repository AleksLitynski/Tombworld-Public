tool # Needed so it runs in the editor.
extends EditorScenePostImport

func disable_filtering(node: Node):
	if node.get_class() == "MeshInstance":
		for idx in node.mesh.get_surface_count():
			var mat = node.mesh.surface_get_material(idx)
			if mat.get_class() == "SpatialMaterial":
				mat.albedo_texture.flags = Texture.FLAG_REPEAT
#				mat.params_use_alpha_scissor = false
#				mat.flags_transparent = true

			node.mesh.surface_set_material(idx, mat)
	
	for child in node.get_children():
		disable_filtering(child)

func center_mesh(scene):
	for child in scene.get_children():
		print("centering mesh ", child.name)
		if child.get_class() == "MeshInstance":
			child.global_transform.origin = Vector3.ZERO
			child.global_transform = child.global_transform.looking_at(Vector3.FORWARD, Vector3.UP)

func post_import(scene):
	print("applying import function")
	disable_filtering(scene)
	center_mesh(scene)
	return scene
