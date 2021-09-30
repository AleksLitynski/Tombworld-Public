extends Node

func l_pad(to_pad, to_pad_with, length_to_pad):
	return pad(true, to_pad, to_pad_with, length_to_pad)

func r_pad(to_pad, to_pad_with, length_to_pad):
	return pad(false, to_pad, to_pad_with, length_to_pad)

func pad(left, to_pad, to_pad_with, length_to_pad):
	var to_add = length_to_pad - len(String(to_pad))
	if to_add > 0:
		var padding = to_pad_with.repeat(to_add)
		if left:
			return padding + String(to_pad)
		else:
			return String(to_pad) + padding
	else:
		return String(to_pad)
