extends HBoxContainer


onready var master_audio_bus = AudioServer.get_bus_index("Master")

func _ready():
	$volume.value = db2linear(AudioServer.get_bus_volume_db(master_audio_bus))


func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(master_audio_bus, linear2db(value))
