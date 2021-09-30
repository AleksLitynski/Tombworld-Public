extends FourColorBullet

func _ready():
	$sprite.directions = [
		{ name = "back", flip = true, pixel_size = 0.005 },
		{ name = "side", pixel_size = 0.01 },
		{ name = "back", pixel_size = 0.005 },
		{ name = "side", flip = true, pixel_size = 0.01 },
	]
	$sprite.pixel_size = 0.005
	$sprite.play("back")
	speed = 30
	damage_type = "green_bullet"
