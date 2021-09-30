extends Node

class_name Door
func get_class(): return "Door"
					 # Door must set:    request_open, open, close
					 # Doorway will set: opening, closing
var state = "closed" # closed, request_open, opening, open, closing // no request_close (doors autoclose when you get too far away)
