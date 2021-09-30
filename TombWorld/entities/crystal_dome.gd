extends KinematicBody

var speed = 15
var dome_transparency setget _set_dome_transparency, _get_dome_transparency
var max_scale = 3
var is_passable = false
var pending_player_exit = false
var dying = false

func _ready():
	$CollisionShape.disabled = true
	$Area.scale = G.v3(0.2)
	$crystal_dome.scale = G.v3(0.2)
	$crystal_dome/Icosphere.mesh = $crystal_dome/Icosphere.mesh.duplicate()
	G.to_unique_materials_mesh($crystal_dome/Icosphere.mesh)
	connect("do_die", self, "_do_die")

func _physics_process(delta):
	if speed > 0:
		move_and_collide(-global_transform.basis.z * delta * speed)

	if pending_player_exit:
		pending_player_exit = try_remove_player()

func become_passable():
	if dying: return
	if is_passable: return
	is_passable = true
	collision_layer = 2
	pending_player_exit = false
	add_collision_exception_with(G.player())
	G.tween_property(self, "dome_transparency", dome_transparency, 0.2, 0.4, Tween.TRANS_LINEAR)

func become_impassable():
	if dying: return
	if not is_passable: return
	is_passable = false
	pending_player_exit = try_remove_player()

func try_remove_player():
	if dying: return
	var contains_player = false
	for body in get_node("Area").get_overlapping_bodies():
		if body == G.player():
			contains_player = true

	if not contains_player:
		collision_layer = 1
		remove_collision_exception_with(G.player())
		G.tween_property(self, "dome_transparency", dome_transparency, 1.0, 0.2, Tween.TRANS_LINEAR)

	return contains_player

func stick():
	speed = 0
	$CollisionShape.disabled = false
	collision_layer = 1
	var td = G.tween_property($CollisionShape, "scale", G.v3(0), G.v3(max_scale), 1.0, Tween.TRANS_LINEAR)
	while $crystal_dome.scale.x < max_scale:
		yield(get_tree().create_timer(0.05), "timeout")
		$crystal_dome.scale += G.v3(0.2)
	
	yield(td, "completed")
	$Area.scale = G.v3(1)
	$CollisionShape.scale = G.v3(1)
	$crystal_dome.scale = G.v3(1)
	scale = G.v3(max_scale)

func _on_Area_body_entered(body):
	if not body.is_in_group("player") and not body.is_in_group("enemy") and speed > 0:
		yield(stick(), "completed")

signal do_die
func die():
	dying = true
	collision_layer = 2
	emit_signal("do_die")

func _get_dome_transparency():
	if not $crystal_dome or not $crystal_dome/Icosphere or not $crystal_dome/Icosphere.mesh:
		return 0
	return G.get_alpha_mesh($crystal_dome/Icosphere.mesh)

func _set_dome_transparency(t):
	G.set_alpha_mesh($crystal_dome/Icosphere.mesh, t)

func _do_die():
	yield(G.tween_property(self, "dome_transparency", dome_transparency, 0, 0.6, Tween.TRANS_LINEAR), "completed")
	queue_free()
