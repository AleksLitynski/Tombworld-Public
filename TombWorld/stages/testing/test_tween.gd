extends Spatial

func _ready():
	print($comb/fuck_crate.translation)
	$comb/fuck_crate.translate(Vector3(0,2,0))
	print($comb/fuck_crate.translation)
#	print(NodePath("move_cylinder_1:global_transform:origin").get_as_property_path())

func _on_Area_body_entered(body):
	print("1")
	print(body.name)
	var c_tween = Tween.new()
	
	c_tween.interpolate_property(
		$comb/fuck_crate,
		"translation",
		$comb/fuck_crate.translation,
		$comb/fuck_crate.translation + Vector3(0,-30,0),
		1,
		Tween.TRANS_LINEAR)
	c_tween.connect("tween_completed", self, "print_g_loc")
	add_child(c_tween)
	c_tween.start()
#	$move_cylinder_1.global_translate(Vector3(0,25,0))
#	$move_cylinder_1.(Vector3(0,25,0))
	pass

func print_g_loc(obj, key):
	print(obj.name)
	print(obj.global_transform.origin)
