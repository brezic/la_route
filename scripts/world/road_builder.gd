@tool
class_name RoadBuilder
extends Path3D
## Génère le maillage de la route le long de la courbe : asphalte, bas-côtés et ligne centrale en pointillés.
## Visuel uniquement : en V0.1 le sol est plat et c'est lui qui porte la collision.

@export_group("Dimensions")
@export var road_width_m: float = 7.0
@export var shoulder_width_m: float = 0.8
## Distance entre deux échantillons de la courbe (plus petit = virages plus lisses).
@export var sample_spacing_m: float = 2.0
## Hauteur au-dessus du sol, pour éviter le scintillement entre route et sol.
@export var surface_height_m: float = 0.02
@export var line_height_m: float = 0.03

@export_group("Marquage")
@export var dash_length_m: float = 3.0
@export var dash_gap_m: float = 9.0
@export var center_line_width_m: float = 0.15

@export_group("Couleurs")
@export var asphalt_color: Color = Color("4d4a47")
@export var shoulder_color: Color = Color("7d7a62")
@export var line_color: Color = Color("d9cfa8")

var _mesh_instance: MeshInstance3D = null


func _ready() -> void:
	rebuild()
	if Engine.is_editor_hint():
		curve_changed.connect(rebuild)


## Longueur de la route, en mètres.
func get_length_m() -> float:
	return curve.get_baked_length() if curve != null else 0.0


func rebuild() -> void:
	if curve == null:
		return
	if _mesh_instance == null:
		_mesh_instance = MeshInstance3D.new()
		add_child(_mesh_instance)
	_mesh_instance.mesh = _build_mesh()
	_mesh_instance.material_override = _build_material()


func _build_mesh() -> ArrayMesh:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var frames: Array[Transform3D] = _sample_frames()
	var half_width_m: float = road_width_m / 2.0
	_add_band(surface, frames, -half_width_m - shoulder_width_m, -half_width_m, shoulder_color)
	_add_band(surface, frames, -half_width_m, half_width_m, asphalt_color)
	_add_band(surface, frames, half_width_m, half_width_m + shoulder_width_m, shoulder_color)
	_add_center_dashes(surface)
	return surface.commit()


func _sample_frames() -> Array[Transform3D]:
	var frames: Array[Transform3D] = []
	var length_m: float = get_length_m()
	var offset_m: float = 0.0
	while offset_m < length_m:
		frames.append(curve.sample_baked_with_rotation(offset_m))
		offset_m += sample_spacing_m
	frames.append(curve.sample_baked_with_rotation(length_m))
	return frames


## Bande continue entre deux distances latérales (négatif = à gauche de la route).
func _add_band(surface: SurfaceTool, frames: Array[Transform3D], inner_m: float, outer_m: float,
		color: Color) -> void:
	for index in frames.size() - 1:
		var start: Transform3D = frames[index]
		var end: Transform3D = frames[index + 1]
		_add_quad(surface, [
			_lateral_point(start, inner_m, surface_height_m), _lateral_point(start, outer_m, surface_height_m),
			_lateral_point(end, outer_m, surface_height_m), _lateral_point(end, inner_m, surface_height_m),
		], color)


func _add_center_dashes(surface: SurfaceTool) -> void:
	var half_line_m: float = center_line_width_m / 2.0
	var length_m: float = get_length_m()
	var dash_start_m: float = 0.0
	while dash_start_m + dash_length_m <= length_m:
		var start: Transform3D = curve.sample_baked_with_rotation(dash_start_m)
		var end: Transform3D = curve.sample_baked_with_rotation(dash_start_m + dash_length_m)
		_add_quad(surface, [
			_lateral_point(start, -half_line_m, line_height_m), _lateral_point(start, half_line_m, line_height_m),
			_lateral_point(end, half_line_m, line_height_m), _lateral_point(end, -half_line_m, line_height_m),
		], line_color)
		dash_start_m += dash_length_m + dash_gap_m


static func _lateral_point(frame: Transform3D, lateral_m: float, height_m: float) -> Vector3:
	return frame.origin + frame.basis.x * lateral_m + Vector3.UP * height_m


static func _add_quad(surface: SurfaceTool, corners: Array[Vector3], color: Color) -> void:
	surface.set_color(color)
	surface.set_normal(Vector3.UP)
	# Ordre des sommets choisi pour que la face visible regarde vers le ciel.
	for corner_index in [0, 2, 1, 0, 3, 2]:
		surface.add_vertex(corners[corner_index])


static func _build_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 1.0
	return material
