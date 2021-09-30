tool
extends Spatial


export(int) var length = 1 setget set_length

var template = preload("res://entities/chain_sprite.tscn")

func set_length(val):
	length = val
	for c in get_children(): c.queue_free()
	for i in length:
		var next = template.instance()
		var h = next.frames.get_frame("default", 0).get_size().y
		next.transform.origin.y -= (i + 1) * h * next.pixel_size
		add_child(next)
