class_name ListRectifier
func get_class(): return "ListRectifier"


static func rectify_lists(old, new, root, item_packed_scene, setup = null, active = null, activate = null, deactivate = null):
	# remove items until our sizes match
	while new.size() < old.size():
		var last_child = root.get_child(root.get_child_count() -1)
		root.remove_child(last_child)
		last_child.queue_free()
		old.pop_back()
	
	# go through each item in new
	var idx = 0
	for item in new:
		# if there's more items in new than in old, add an item to the end
		if idx >= old.size():
			old.push_back("")
			var new_item = item_packed_scene.instance()
			root.add_child(new_item)
		
		var node = root.get_child(idx)
		
		# if the current item doesn't match what's expected, rectify it
		var current = old[idx]
		if current != item:
			old[idx] = item
			if setup:
				setup.call_func(node, item, root)
		idx += 1

		if active or active == "":
			if item == active:
				if activate:
					activate.call_func(node, item, root)
			else:
				if deactivate:
					deactivate.call_func(node, item, root)

