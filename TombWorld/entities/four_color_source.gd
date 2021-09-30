extends Particles

signal do_die

export(String, "red", "blue", "yellow", "green") var color = "green"
export(bool) var can_die = true

func _ready():
	get_parent().set_meta("four_color_source", self)
	connect("do_die", self, "_do_die")
	process_material = process_material.duplicate()

func _process(delta):
	set_color(color)

func set_color(value):
	process_material.color = G.data_tables.four_color_colors[value]
	color = value

func die():
	if can_die:
		get_parent().remove_meta("four_color_source")
		emit_signal("do_die")

func _do_die():
	emitting = false
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()
