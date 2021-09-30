tool
extends Spatial


export(SpatialMaterial) var material = SpatialMaterial.new() setget set_material


func _ready():
	set_material(material)

func set_material(mat):
	material = mat
	$hex_circle.material_override = mat
