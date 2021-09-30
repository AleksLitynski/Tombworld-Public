extends Gun

var fire_delay
var initial_fire_delay = 0.2
var min_fire_delay = 0.03
var last_fire_time = 0
var is_firing = false
var confidence_factor
var scan_target

func _ready():
	._ready()
	$shoot_sprite.visible = false
	$gun_sprite.frame = 0
	G.player().gun_manager.connect("trigger_pressed", self, "_trigger_pressed")
	G.player().gun_manager.connect("trigger_released", self, "_trigger_released")
	
func start_anim():
	$shoot_sprite.visible = true
	$shoot_sprite.play("default")
	yield(G.tween_property($shoot_sprite, "modulate:a", 0, 0.75, .2, Tween.TRANS_LINEAR), "completed")

func stop_anim():
	yield(G.tween_property($shoot_sprite, "modulate:a", 0.75, 0, .2, Tween.TRANS_LINEAR), "completed")
	# once its faded, hide it and reset everything
	$shoot_sprite.stop()
	$shoot_sprite.visible = false

func _trigger_pressed():
	confidence_factor = 0
	fire_delay = initial_fire_delay
	$gun_sprite.frame = 0
	is_firing = true
	yield(start_anim(), "completed")
	
func _trigger_released():
	yield(stop_anim(), "completed")
	is_firing = false

func _process(delta):
	if is_firing and G.game_time - fire_delay >= last_fire_time:
		last_fire_time = G.game_time
		$sfx.play()
		var b = fire_bullet(preload("res://entities/bullets/scan_fire.tscn").instance())
		b.starting_velo = G.at_height(G.player().velocity, 0)
		b.confidence_factor = confidence_factor
		b.on_scan_hit = funcref(self, "_on_scan_hit")

func _on_scan_hit(hit):
	var valid_target = false
	if G.can_be_scanned(hit.collider) and not G.dialog.showing_dialog():
		valid_target = true
		if confidence_factor >= 100:
			var scan_tag = G.get_scan_tag(hit.collider)
			$gun_sprite.frame = 4 # max scan level only when we successfully scanned
			G.dialog.show_dialog_and_save(scan_tag)
			confidence_factor = 0
			fire_delay = initial_fire_delay

	if scan_target != hit.collider or not valid_target:
		scan_target = hit.collider
		confidence_factor = 0
		fire_delay = initial_fire_delay

	if confidence_factor < 100:
		confidence_factor += 1
		if fire_delay > min_fire_delay:
			fire_delay -= 0.01
	
	# map 0-3 scan levels while building confidence
	$gun_sprite.frame = floor(G.map_range(confidence_factor, 0, 100, 0, 3))
