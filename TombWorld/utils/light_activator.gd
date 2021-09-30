extends Node
class_name LightActivator

func _ready():
	tag_lights(get_tree().root)
	get_tree().connect("node_added", self, "node_added_to_tree")

var last_light_update = 0
var prev_play_pos = null
func _process(delta):
	# Every half second, update the lights so the nearest 8 are on
	if G.game_time - 0.5 >= last_light_update and G.player():
		if prev_play_pos == null or prev_play_pos.distance_squared_to(G.player_pos()) > 0.1:
			last_light_update = G.game_time
			prev_play_pos = G.player_pos()
			update_lights()

func node_added_to_tree(node):
	tag_lights(node)

func tag_lights(root):
	if root is Light:
		root.add_to_group("light")
	for child in root.get_children():
		tag_lights(child)

func sort_lights(l1, l2):
	return l1.global_transform.origin.distance_squared_to(G.camera().global_transform.origin) \
		< l2.global_transform.origin.distance_squared_to(G.camera().global_transform.origin)

func update_lights():
	var lights = get_tree().get_nodes_in_group("light")
	lights.sort_custom(self, "sort_lights")
	for light_idx in range(lights.size()):
		lights[light_idx].visible = light_idx <= 8
