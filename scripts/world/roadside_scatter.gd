class_name RoadsideScatter
extends Node3D
## Disperse des sapins low poly de part et d'autre de la route, à partir d'une graine.
## Un seul MultiMesh pour l'affichage et un seul corps statique pour les collisions (performances).

@export var road: Path3D
@export var seed_value: int = 1978
@export var tree_count: int = 350
## Distance minimale à la route (laisse les bas-côtés dégagés).
@export var min_distance_to_road_m: float = 12.0
@export var max_distance_to_road_m: float = 160.0
@export var min_tree_height_m: float = 5.0
@export var max_tree_height_m: float = 11.0
## Rapport largeur / hauteur de la couronne.
@export var crown_width_ratio: float = 0.38
@export var trunk_collision_radius_m: float = 0.35
@export var trunk_collision_height_m: float = 3.0
@export var tree_color: Color = Color("4e6e3a")

const CONE_RADIAL_SEGMENTS: int = 6
const MAX_PLACEMENT_ATTEMPTS_PER_TREE: int = 8


func _ready() -> void:
	var transforms: Array[Transform3D] = _generate_tree_transforms()
	add_child(_build_multimesh_instance(transforms))
	add_child(_build_collision_body(transforms))


func _generate_tree_transforms() -> Array[Transform3D]:
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = seed_value
	var transforms: Array[Transform3D] = []
	for _tree_index in tree_count:
		for _attempt in MAX_PLACEMENT_ATTEMPTS_PER_TREE:
			var candidate: Vector3 = _random_roadside_position(random)
			if _is_far_enough_from_road(candidate):
				transforms.append(_tree_transform(candidate, random))
				break
	return transforms


func _random_roadside_position(random: RandomNumberGenerator) -> Vector3:
	var curve: Curve3D = road.curve
	var frame: Transform3D = curve.sample_baked_with_rotation(random.randf() * curve.get_baked_length())
	var side: float = 1.0 if random.randf() < 0.5 else -1.0
	var distance_m: float = random.randf_range(min_distance_to_road_m, max_distance_to_road_m)
	var local_position: Vector3 = frame.origin + frame.basis.x * side * distance_m
	return road.global_transform * Vector3(local_position.x, 0.0, local_position.z)


## Vérifie que l'arbre n'est pas sur une autre portion de la route (dans un virage).
func _is_far_enough_from_road(world_position: Vector3) -> bool:
	var local_position: Vector3 = road.to_local(world_position)
	var closest: Vector3 = road.curve.get_closest_point(local_position)
	return Vector2(local_position.x - closest.x, local_position.z - closest.z).length() >= min_distance_to_road_m


func _tree_transform(world_position: Vector3, random: RandomNumberGenerator) -> Transform3D:
	var height_m: float = random.randf_range(min_tree_height_m, max_tree_height_m)
	var width_m: float = height_m * crown_width_ratio
	var tree_basis: Basis = Basis(Vector3.UP, random.randf() * TAU).scaled(Vector3(width_m, height_m, width_m))
	# Le cône de base fait 1 m de haut et est centré : on le remonte d'une demi-hauteur.
	return Transform3D(tree_basis, world_position + Vector3.UP * height_m / 2.0)


func _build_multimesh_instance(transforms: Array[Transform3D]) -> MultiMeshInstance3D:
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = _build_cone_mesh()
	multimesh.instance_count = transforms.size()
	for index in transforms.size():
		multimesh.set_instance_transform(index, global_transform.affine_inverse() * transforms[index])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	return instance


func _build_cone_mesh() -> CylinderMesh:
	var cone: CylinderMesh = CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.5
	cone.height = 1.0
	cone.radial_segments = CONE_RADIAL_SEGMENTS
	cone.rings = 0
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = tree_color
	material.roughness = 1.0
	cone.material = material
	return cone


func _build_collision_body(transforms: Array[Transform3D]) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var trunk_shape: CylinderShape3D = CylinderShape3D.new()
	trunk_shape.radius = trunk_collision_radius_m
	trunk_shape.height = trunk_collision_height_m
	for tree_transform in transforms:
		# Le tronc part du sol, sous le centre de la couronne.
		var ground_position: Vector3 = tree_transform.origin - Vector3.UP * tree_transform.basis.get_scale().y / 2.0
		var shape_node: CollisionShape3D = CollisionShape3D.new()
		shape_node.shape = trunk_shape
		shape_node.position = to_local(ground_position + Vector3.UP * trunk_collision_height_m / 2.0)
		body.add_child(shape_node)
	return body
