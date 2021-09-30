extends Enemy

var normal_hit = []
var weak_spot = []

func _ready():
	$AnimatedSprite3D.directions = [{name = "default"}]
	normal_hit.append($body_target)
	weak_spot.append($head_target)
