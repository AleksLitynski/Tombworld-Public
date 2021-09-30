extends Spatial

# Called when the node enters the scene tree for the first time.
var state = "wave_1"
func _ready():
	if G.game_state.stage_state.has(str(get_path())):
		var ss = G.game_state.stage_state[str(get_path())]
		if ss.has("cleared") and ss.cleared:
			$Navigation/wave_1.queue_free()
			$Navigation/wave_2.queue_free()
			$Navigation/wave_3.queue_free()
			state = "completed"
	else:
		G.game_state.stage_state[str(get_path())] = {}
	
	set_wave_acting($Navigation/wave_1, false)
	set_wave_acting($Navigation/wave_2, false)
	set_wave_acting($Navigation/wave_3, false)
	if state != "completed":
		set_wave_acting($Navigation/wave_1, true)

func open_wave_two():
	set_wave_acting($Navigation/wave_2, true)
	$doors_and_gates/wave_2_1.open()
	$doors_and_gates/wave_2_2.open()
	state = "wave_2"

func open_wave_three():
	set_wave_acting($Navigation/wave_3, true)
	$doors_and_gates/wave_3_1.open()
	$doors_and_gates/wave_3_2.open()
	state = "wave_3"
	
func success():
	# open the last door
	$doors_and_gates/success.open()
	state = "completed"
	
	# lock in the victory
	$doors_and_gates/wave_2_1.save_state()
	$doors_and_gates/wave_2_2.save_state()
	$doors_and_gates/wave_3_1.save_state()
	$doors_and_gates/wave_3_2.save_state()
	G.game_state.stage_state[str(get_path())].cleared = true

func _process(delta):
	match state:
		"wave_1":
			if $Navigation/wave_1.get_children().size() == 0:
				open_wave_two()
		"wave_2":
			if $Navigation/wave_2.get_children().size() == 0:
				open_wave_three()
		"wave_3":
			if $Navigation/wave_3.get_children().size() == 0:
				success()

func set_wave_acting(wave, state):
	for e in wave.get_children():
		if e.is_in_group("enemy"):
			if state:
				e.acting_lock -= 1
			else:
				e.acting_lock += 1
