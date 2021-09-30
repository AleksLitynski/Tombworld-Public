extends Spatial

var checkpoint = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$walls_and_floor/lava_hitbox.connect("body_entered", self, "cp_respawn")
	$checkpoints/cp_2.connect("body_entered", self, "cp_2_set_respawn")
	$checkpoints/cp_3.connect("body_entered", self, "cp_3_set_respawn")
	$checkpoints/cp_4.connect("body_entered", self, "cp_4_set_respawn")
	
	for hurt_pylon in $traps.get_children():
		hurt_pylon.connect("body_entered", self, "cp_respawn")

	$walls_and_floor/ceiling.visible = true
	$walls_and_floor/ceiling2.visible = true
	$walls_and_floor/ceiling3.visible = true
	$walls_and_floor/ceiling4.visible = true
	
	log_scaled_meshes(self)

func log_scaled_meshes(i):
	if i is MeshInstance and (i.scale != G.v3(1) or i.transform.origin != G.v3(0)):
		print(str(i.get_path()))
	for c in i.get_children():
		log_scaled_meshes(c)

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
		var player_move_pos = get_node("checkpoints/cp_%s" % checkpoint)
		body.velocity = Vector3.ZERO
		body.dash.active = false
		body.take_damage("hurt_floor")
		body.global_transform.origin = player_move_pos.global_transform.origin
		body.freeze_accel = true
		yield(get_tree().create_timer(.5), "timeout")
		body.freeze_accel = false
