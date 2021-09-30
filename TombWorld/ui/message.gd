extends MarginContainer


export(String) var message = "Hello!" setget _set_message
export(String) var speaker = "Lario" setget _set_speaker
export(Texture) var icon = preload("res://assets/portraits/bad-face-1.png") setget _set_icon
export(bool) var flipped = false setget _set_flipped

func _set_message(value):
	$contents/icon_and_message/message_margins/message.bbcode_text = value
	message = value

func _set_speaker(value):
	$contents/icon_and_message/icon/sender/label.text = value
	speaker = value

func _set_icon(value):
	$contents/icon_and_message/icon/sender/image.texture = value
	icon = value

func _set_flipped(value):
	var icon_and_message = $contents/icon_and_message
	if value:
		icon_and_message.move_child($contents/icon_and_message/message_margins, 0)
	else:
		icon_and_message.move_child($contents/icon_and_message/icon, 0)
	flipped = value
