extends Node
class_name DialogTag

# should be a key in G.data_tables.dialogs
export(String) var tag = ""

func _process(delta):
	tag_first_collider(get_parent())
	add_to_group("scan_tag")

func tag_first_collider(target):
	if target is PhysicsBody or target is CSGShape:
		target.add_to_group("scannable")
		self.get_parent().remove_child(self)
		target.add_child(self)
		return true
	for c in target.get_children():
		if tag_first_collider(c):
			return true
	
	return false
