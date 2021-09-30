extends Area

# To use:
# 1. Add a collision shape child node to indicate when to start pre-loading the next room
# 2. Add a 'door' mesh child node that listens for the 'door_open' and 'door_close' events we will emit to request the barrier be removed
# 3. Position this node at the transform the adjacent room should load into (the matching door in the other room will be positioned exactly where this node is
# 4. Set the name of the connected stage and the name of this door. There must be a door on the connected stage with a matching name
# 5. When you determine the player wants to open the door, call the 'request_open' function. Locking the door is up to you!
# 5. Add an area to the stage in the group "stage_area"

export(String) var target_stage_name
export(String) var door_name

var current_stage: Node
var target_stage
var door: Node

# Utils
func stage_is_loading(): return (typeof(target_stage) == TYPE_STRING) and (target_stage == "loading")
func stage_is_loaded(): return target_stage != null and (typeof(target_stage) != TYPE_STRING)
func player_in_trigger(): return get_overlapping_bodies().has(G.player())
func in_our_stage_not_targets():
	if !target_stage or stage_is_loading(): return true
	var current_stages_names = G.get_current_stages_names()
	return current_stages_names.has(G.get_node_stage_name(self)) and !current_stages_names.has(G.get_node_stage_name(target_stage))
func get_matching_doorway():
	for doorway in get_tree().get_nodes_in_group("doorway"):
		if doorway.door_name == door_name and G.get_node_stage_name(doorway) == target_stage_name:
			return doorway

func _ready():
	current_stage = G.get_node_stage(self)
	target_stage = null

	# Find the door mesh
	for child in get_children():
		if child.get_class() == "Door":
			door = child
			break

func _on_i_doorway_body_entered(body):
	if body.is_in_group("player"):
		if stage_is_loading():
			# the target stage is already loading
			return
		if target_stage == null:
			G.stage_loader.request_load(target_stage_name, funcref(self, "_on_stage_loaded"))
			target_stage = "loading"
			# start loading the next stage

func _on_i_doorway_body_exited(body):
	if body.is_in_group("player"):
		if stage_is_loading():
			G.stage_loader.cancel_load(target_stage_name)
			target_stage = null

		# if we exited back into our area and no other area, 
		if in_our_stage_not_targets():
			door.state = "closing"

func _on_stage_loaded(target_stage):
	# add the new stage to the scene
	var target_door = get_matching_doorway()

	# this only works on the Y axis. If the mesh is rotation on the X or Z axis, it breaks. IDK why.
	target_stage.global_transform *= (target_door.door.global_transform * door.global_transform.inverse()).inverse()
	target_stage.global_transform.origin -= (target_door.door.global_transform.origin - door.global_transform.origin)

	# share a single door mesh
	target_door.door.queue_free()
	target_door.door = door
	
	target_stage.visible = true
	self.target_stage = target_stage
	target_door.target_stage = current_stage

func _process(delta):
	if door.state == "closed" and stage_is_loaded() and in_our_stage_not_targets() and !player_in_trigger():
		var pos = door.global_transform
		G.safe_add_child(self, door) # claim the door
		door.global_transform = pos
		G.remove_stage(target_stage_name) # and free the other stage
		target_stage = null

	if stage_is_loaded() and door.state == "request_open":
		door.state = "opening"

# Player enters dt1 ->
# Player exits dt1 ->
# Player

# [in dt1] -> load stage
# [request_door_open] -> load stage
# [request_door_open, stage loaded, in dt1] -> open door
# [out dt1, not in stage] -> unload stage, close door (then unload new stage)
# [out dt1, in stage, out dt2] -> close door (then unload origional stage)




# Known issues:
# 	- Sometimes, the door will open without the next room having loaded (so weird)
#   - doors can only be rotated on the Y axis. This will not be fixed
#   - If you go no-clip, triggers act weird and bad
#   - if door.state == "closed" was once null. IDK why

