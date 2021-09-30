extends Spatial

var checkpoint = 1

func _ready():
	$weapon_pedestals_2.connect("on_pickup", self, "lower_inital")
	$cp_1/Area.connect("body_entered", self, "cp_1_set_respawn")
	$cp_2/Area2.connect("body_entered", self, "cp_2_set_respawn")

	$walls_and_floor/floor1/MeshInstance.get_surface_material(0).albedo_texture.pause = false
	$walls_and_floor/floor2/MeshInstance.get_surface_material(0).albedo_texture.pause = false

	$walls_and_floor/lava_collider.connect("body_entered", self, "cp_respawn")
	$walls_and_floor/lava_collider.connect("body_entered", self, "cp_respawn")
	$pillars_challenge/move_cylinder_79


func lower_inital():
	checkpoint = 2
	$pillars_move_anim.connect("animation_finished", self, "remove_inital")
	$pillars_move_anim.play("raise_challenge")

	$cp_1/Area.disconnect("body_entered", self, "cp_1_set_respawn")
	$cp_2/Area2.disconnect("body_entered", self, "cp_2_set_respawn")

	$cp_3/Area3.connect("body_entered", self, "cp_3_set_respawn")
	$cp_4/Area4.connect("body_entered", self, "cp_4_set_respawn")

	for n in range(79, 90):
		var hurt_pylon = get_node("pillars_challenge/move_cylinder_%s" % n)
		hurt_pylon.connect("body_entered", self, "cp_respawn")

func remove_inital(body):
	if $pillars_initial:
		$pillars_inital.free()

func cp_1_set_respawn(body):
	if body.is_in_group("player"):
		checkpoint = 1

func cp_2_set_respawn(body):
	if body.is_in_group("player"):
		checkpoint = 2

func cp_3_set_respawn(body):
	if body.is_in_group("player"):
		checkpoint = 3

func cp_4_set_respawn(body):
	if body.is_in_group("player"):
		checkpoint = 4

func cp_respawn(body):
	if body.is_in_group("player"):
		var player_move_pos = get_node("cp_%s" % checkpoint)
		body.dash.active = false
		body.take_damage("hurt_floor")
		body.velocity = Vector3.ZERO
		body.global_transform.origin = player_move_pos.global_transform.origin
		body.freeze_accel = true
		yield(get_tree().create_timer(1.5), "timeout")
		body.freeze_accel = false
