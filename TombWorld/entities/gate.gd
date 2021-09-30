tool
extends Spatial


export(Vector2) var size = Vector2(2, 3) setget set_size
export(Texture) var texture = preload("res://assets/tiles/catwalk_rail.png") setget set_texture
export(bool) var auto_save = true
var starting_pos
var state = "closed"

# Called when the node enters the scene tree for the first time.
func _ready():
	$StaticBody/CollisionShape.shape = $StaticBody/CollisionShape.shape.duplicate()
	starting_pos = $StaticBody.transform.origin
	set_size(size)
	if G.game_state.gates.has(str(get_path())) and G.game_state.gates[str(get_path())] == "open":
		$StaticBody.transform.origin = get_open_target()
		state = "open"

func set_texture(tex):
	texture = tex
	set_size(size)

func set_size(val):
	if not $StaticBody/CollisionShape: return
	size = val
	$StaticBody/CollisionShape.shape.extents.x = 0
	$StaticBody/CollisionShape.shape.extents.y = 0
	for c in $StaticBody/segments.get_children(): c.queue_free()
	var tile_size
	for x in size.x:
		for y in size.y:
			var s = Sprite3D.new()
			s.texture = texture
			s.pixel_size = 0.0155
			tile_size = s.texture.get_size() * s.pixel_size
			$StaticBody/segments.add_child(s)
			s.transform.origin.x += tile_size.x * x + (tile_size.x / 2)
			s.transform.origin.y += tile_size.y * y + (tile_size.y / 2)

	if tile_size:
		$StaticBody/CollisionShape.shape.extents.x = (size.x * tile_size.x) / 2
		$StaticBody/CollisionShape.shape.extents.y = (size.y * tile_size.y) / 2
		$StaticBody/CollisionShape.transform.origin.x = (size.x * tile_size.x) / 2
		$StaticBody/CollisionShape.transform.origin.y = (size.y * tile_size.y) / 2

func _process(delta):
	if is_open_button_pressed():
		open()

func is_open_button_pressed():
	if Engine.editor_hint: return false
	for c in get_children():
		if c.name == "__open_button":
			return c.is_pressed()
	return false

func get_open_target():
	for c in get_children():
		if c.name == "__open_target":
			return c.transform.origin
	return starting_pos

func open():
	var open_target = get_open_target()
	state = "open"
	if auto_save:
		G.game_state.gates[str(get_path())] = "open"
	yield(G.tween_property($StaticBody, "translation", $StaticBody.transform.origin, open_target, 3.0), "completed")


func close():
	state = "closed"
	if auto_save:
		G.game_state.gates[str(get_path())] = "closed"
	yield(G.tween_property($StaticBody, "translation", $StaticBody.transform.origin, starting_pos, 3.0), "completed")

func save_state():
		G.game_state.gates[str(get_path())] = state
