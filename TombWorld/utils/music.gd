extends AudioStreamPlayer

var track_idx = -1
var main_tracks = [
	preload("res://audio/Marcos H. Bolanos - Verita.mp3"),
	preload("res://audio/Pariah_-_Zodiac.mp3"),
]

var boss_tracks = [
	preload("res://audio/Defrini_-_Speedrave.mp3.mp3")
]

var mode = "main"

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(0.2))
	play_next_track()

func set_mode(new_mode):
	mode = new_mode
	track_idx = -1
	play_next_track()

func play_next_track():
	var tracks = main_tracks if mode == "main" else boss_tracks
	track_idx += 1
	track_idx = track_idx % tracks.size()
	stream = tracks[track_idx]
	play()

func _on_music_finished():
	play_next_track()

func _process(delta):
	var stages = G.get_current_stages_names()
	if "the_gorgons_lair" in stages and stages.size() == 1:
		if mode != "boss": set_mode("boss")
	else:
		if mode != "main": set_mode("main")
