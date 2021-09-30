extends Spatial

func _process(delta):
	var nav = $Navigation
	var on_mesh = nav.get_closest_point(nav.global_transform.xform_inv($Spatial.global_transform.origin))
	var on_mesh_owner = nav.get_closest_point_owner($Spatial.global_transform.origin)
	$start.global_transform.origin = $Spatial.global_transform.origin
	$end.global_transform.origin = nav.global_transform.xform(on_mesh)
	
	print(on_mesh)


func _input(ev):
	if ev.is_action_pressed("strafe_left"): $Spatial.global_transform.origin.x -= 5
	if ev.is_action_pressed("strafe_right"): $Spatial.global_transform.origin.x += 5
	if ev.is_action_pressed("move_forward"): $Spatial.global_transform.origin.z -= 5
	if ev.is_action_pressed("move_back"): $Spatial.global_transform.origin.z += 5
