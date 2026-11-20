@tool
class_name BiomeGround
extends MeshInstance3D
## Sol uni à la couleur du biome.

@export var biome: BiomeData:
	set(value):
		biome = value
		_apply_biome()


func _ready() -> void:
	_apply_biome()


func _apply_biome() -> void:
	if biome == null:
		return
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = biome.ground_color
	material.roughness = 1.0
	material_override = material
