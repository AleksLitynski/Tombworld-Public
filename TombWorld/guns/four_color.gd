extends Gun


var fire_delay = 0.18
var last_fire_time = 0

signal animate_switch_color(color)

onready var particles = $Particles
func _ready():
	._ready()
	G.player().gun_manager.connect("trigger_pressed", self, "_trigger_pressed")
	connect("animate_switch_color", self, "_animate_switch_color")
	G.safe_add_child(G.camera(), particles)

func _exit_tree():
	particles.queue_free()

func set_color(new_color):
	match new_color:
		"blue": $gun_sprite.frame = 0
		"red": $gun_sprite.frame = 1
		"yellow": $gun_sprite.frame = 2
		"green": $gun_sprite.frame = 3

func _process(delta):
	if G.player().gun_manager.trigger_down and G.game_time - fire_delay >= last_fire_time:
		last_fire_time = G.game_time
		_trigger_pressed()
	set_color(G.game_state.stats.active_color_gun_color)

func _trigger_pressed():
	$sfx.play()
	var b = fire_bullet(G.data_tables.four_color_bullets[G.game_state.stats.active_color_gun_color].instance())
	b.on_color_hit = funcref(self, "_on_hit_color")

func _on_hit_color(four_color_source):
	if four_color_source.color != G.game_state.stats.active_color_gun_color and four_color_source.color in G.game_state.stats.color_gun_colors:
		four_color_source.die()
		emit_signal("animate_switch_color", four_color_source.color)

func _animate_switch_color(color):
	particles.process_material.color = G.data_tables.four_color_colors[color]
	particles.global_transform.origin = G.camera().global_transform.origin + G.camera().project_ray_normal(bullet_origin.global_position)
	particles.emitting = true
	yield(get_tree().create_timer(0.95), "timeout")
	G.game_state.stats.active_color_gun_color = color
