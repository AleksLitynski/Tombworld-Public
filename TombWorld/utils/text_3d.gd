tool
extends Spatial
class_name Text3d

export(String) var text = "[TODO]" setget set_text
export(Color) var color = Color.red setget set_color
export(int) var size = 32 setget set_size
export(Vector2) var billboard_size = Vector2(750, 750) setget set_billboard_size
export(bool) var billboard = true setget set_billboard

func _ready():
	$MeshInstance.mesh = $MeshInstance.mesh.duplicate()
	$MeshInstance.material_override = $MeshInstance.material_override.duplicate()
	$Viewport/Label.theme = $Viewport/Label.theme.duplicate()
	$Viewport/Label.theme.default_font = $Viewport/Label.theme.default_font.duplicate()
	set_text(text)
	set_color(color)
	set_size(size)
	set_billboard(billboard)

func set_text(input):
	$Viewport/Label.bbcode_text = "[center]%s[/center]" % input
	text = input

func set_color(input):
	$Viewport/Label.set("custom_colors/default_color", input)
	color = input

func set_size(input):
	$Viewport/Label.theme.default_font.size = input
	size = input

func set_billboard_size(input):
	billboard_size = input
	$Viewport.size = input
	$Viewport/Label.rect_size = input
	$MeshInstance.mesh.size = input / 500

func set_billboard(input):
	billboard = input
	$MeshInstance.material_override.params_billboard_mode = SpatialMaterial.BILLBOARD_FIXED_Y if input else SpatialMaterial.BILLBOARD_DISABLED
