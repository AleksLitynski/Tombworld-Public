extends Spatial


var THE_gordon_acting
var orig_speed
func _ready():
	THE_gordon_acting = false
	orig_speed = $Navigation/enemies/THE_gordon.speed
	$Navigation/enemies/THE_gordon.speed = 0
	$Navigation/enemies/THE_gordon.acting_lock += 1
	
	if G.game_state.stage_state.has(str(get_path())):
		var ss = G.game_state.stage_state[str(get_path())]
		if ss.has("cleared") and ss.cleared:
			$Navigation/enemies.queue_free()
	else:
		G.game_state.stage_state[str(get_path())] = {
			cleared = false
		}

func _process(delta):
	if $Navigation/enemies and $Navigation/enemies.get_child_count() == 0 \
		and G.game_state.stage_state[str(get_path())].cleared == false:

		G.dialog.show_dialog_and_save("Confronting Sir or Madame")
		G.game_state.stage_state[str(get_path())].cleared = true

func _on_room_entered_trigger_body_entered(body):
	if not THE_gordon_acting and $Navigation/enemies/THE_gordon:
		THE_gordon_acting = true
		yield(get_tree().create_timer(10), "timeout")
		$Navigation/enemies/THE_gordon.speed = orig_speed
		$Navigation/enemies/THE_gordon.acting_lock -= 1
