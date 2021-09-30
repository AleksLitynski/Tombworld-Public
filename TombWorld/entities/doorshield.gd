extends StaticBody

export(Color) var color = Color.green
export(String) var damage_type = "green_bullet"

var player_in_shield = false
var is_down = false
var down_time = 0
var wait_time = 5
var up_trans = 0.7
var trans setget _set_trans, _get_trans

func _ready():
	G.to_unique_materials($MeshInstance)
	G.set_color($MeshInstance, color)
	_set_trans(up_trans)
	
func parent_door_closed():
	if not get_parent().is_in_group("doorway"): return true
	return get_parent().door.state == "closed"

func _process(delta):
	if not parent_door_closed() and not is_down:
		take_damage(damage_type)
		
	if is_down and G.game_time > down_time + wait_time:
		if player_in_shield or not parent_door_closed():
			down_time += wait_time
		else:
			is_down = false
			G.tween_property(self, "trans", trans, up_trans, 1.5, Tween.TRANS_LINEAR)
			$CollisionShape.disabled = false

func take_damage(source):
	if source == damage_type:
		down_time = G.game_time
		is_down = true
		G.tween_property(self, "trans", trans, 0, 0.6, Tween.TRANS_LINEAR)
		_set_trans(0)
		$CollisionShape.disabled = true

func _get_trans(): return trans
func _set_trans(t):
	G.set_alpha($MeshInstance, t)
	trans = t

func _on_Area_body_entered(body):
	if body.is_in_group("player"):
		player_in_shield = true

func _on_Area_body_exited(body):
	if body.is_in_group("player"):
		player_in_shield = false
