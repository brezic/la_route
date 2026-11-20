class_name WarningLight
extends MeshInstance3D
## Voyant du tableau de bord : éteint (sombre) ou allumé (lumineux).

@export var lit_color: Color = Color("c8372d")
@export var unlit_color: Color = Color("2a2622")
@export var lit_emission_energy: float = 2.0

var _material: StandardMaterial3D = StandardMaterial3D.new()


func _ready() -> void:
	_material.emission_enabled = true
	material_override = _material
	set_lit(false)


func set_lit(is_lit: bool) -> void:
	_material.albedo_color = lit_color if is_lit else unlit_color
	_material.emission = lit_color if is_lit else Color.BLACK
	_material.emission_energy_multiplier = lit_emission_energy if is_lit else 0.0
