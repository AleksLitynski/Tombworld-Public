extends Gun

func _ready():
	._ready()
	G.player().gun_manager.connect("trigger_pressed", self, "_trigger_pressed")
	G.player().gun_manager.connect("trigger_released", self, "_trigger_released")

func _process(delta):
	var trigger_down = G.player().gun_manager.trigger_down
	if trigger_down: request_fire()

func _trigger_pressed():
	$sfx.play()
	request_fire(true)

func _trigger_released():
	request_fire(true)

var fire_delay = 0.05
var last_fire_time = 0
func request_fire(force = false):
	if G.game_time - fire_delay >= last_fire_time or force:
		fire_gun()

func fire_gun():
	last_fire_time = G.game_time
	var bullet = preload("res://entities/bullets/slime_ball.tscn").instance()
	fire_bullet(bullet)

func _on_sfx_finished():
	if G.player().gun_manager.trigger_down:
		$sfx.play()
