tool
extends StaticBody

export(String) var action_name = "call elevator" setget set_action_name

func set_action_name(val):
	action_name = val
	$text_3d.text = "[E to %s]" % val

func is_pressed():
	return G.is_collider_pressed($button)
