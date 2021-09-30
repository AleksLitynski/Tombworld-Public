extends Door

var prev_state = "closed"

func anim_done(name):
	state = "opened" if state == "opening" else "closed"

func _ready():
	$AnimationPlayer.connect("animation_finished", self, "anim_done")


func _process(delta):
	match state:
		"opening":
			if prev_state != "opening":
				if !$AnimationPlayer.is_playing() and $AnimationPlayer.current_animation_position != 0:
					anim_done("open")
				else:
					$AnimationPlayer.play("open")
		"closing":
			if prev_state != "closing":
				if $AnimationPlayer.current_animation_position == 0:
					anim_done("open")
				else:
					$AnimationPlayer.play_backwards("open")
	prev_state = state
	
	$text_3d.visible = state == "closed"
	$text_3d2.visible = state == "closed"
	
	if G.is_collider_pressed([$door_left, $door_right]):
		state = "request_open"

