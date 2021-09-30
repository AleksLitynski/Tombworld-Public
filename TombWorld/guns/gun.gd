extends Node2D

class_name Gun

var automatic
var warmup
var cooldown
var bullets_ignore_player = true

onready var gun_sprite = $gun_sprite
onready var bullet_origin = $bullet_origin

func _ready():
	get_tree().get_root().connect("size_changed", self, "fix_position")

# override if needed
func get_bounds():
	return $gun_sprite.frames.get_frame("default", 0).get_size() * scale

func get_position():
	var vp = G.main.get_viewport().get_visible_rect().size
	var bounds = get_bounds()
	# center the image over middle of the screen so its always a little to the left
	return Vector2((vp.x / 2) - (bounds.x / 2),  vp.y - bounds.y) 

func fix_position():
	position = get_position()

func spawn_bullet_at_origin(bullet):
	var player = G.player()
	if not player: return

	if bullets_ignore_player:
		bullet.add_collision_exception_with(player)
	
	# add to tree
	G.common_root.add_child(bullet)
	return bullet
	

func fire_bullet(bullet):
	var player = G.player()
	if not player: return

	# spawn the bullet
	spawn_bullet_at_origin(bullet)
	
	# set position
	bullet.global_transform.origin = G.camera().global_transform.origin \
		+ G.camera().project_ray_normal(bullet_origin.global_position)

	# set bullet direction
	var destination_position = Vector3()
	if player.looking_at and player.looking_at.position and player.looking_at.distance_to > 3:
		destination_position = player.looking_at.position
	else:
		destination_position = G.camera().global_transform.origin \
			+ G.camera().project_ray_normal(get_viewport().get_visible_rect().size / 2) * 50
	bullet.look_at(destination_position, Vector3.UP)
	
	if bullet.has_method("_bullet_setup_complete"):
		bullet._bullet_setup_complete()

	return bullet
