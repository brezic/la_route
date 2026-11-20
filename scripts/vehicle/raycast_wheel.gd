class_name RaycastWheel
extends RayCast3D
## Roue simulée par un rayon : suspension (ressort + amortisseur) et adhérence du pneu.
## Le contrôleur du véhicule remplit les commandes (traction, freinage) puis appelle les deux étapes de force.

@export_group("Géométrie")
@export var wheel_radius_m: float = 0.29
@export var suspension_travel_m: float = 0.2
## Pivot visuel de la roue (déplacé par la suspension, tourne avec la vitesse).
@export var wheel_visual: Node3D

@export_group("Suspension")
@export var spring_stiffness_n_per_m: float = 26000.0
@export var damping_n_per_mps: float = 1500.0

@export_group("Pneu")
## Coefficient de frottement du pneu neuf sur asphalte sec.
@export var tire_friction_coefficient: float = 1.0
## Part du glissement latéral corrigée à chaque pas (trop proche de 1 rend la voiture instable).
@export_range(0.0, 1.0) var lateral_stiffness: float = 0.6

@export_group("Rôle")
@export var is_driven: bool = false
@export var is_steering: bool = false
@export var has_handbrake: bool = false

# Commandes fournies par le contrôleur à chaque pas physique.
var drive_force_n: float = 0.0
var brake_force_n: float = 0.0
var lateral_grip_factor: float = 1.0
## Adhérence du sol (vient du biome).
var surface_grip_factor: float = 1.0

var normal_force_n: float = 0.0
var is_grounded: bool = false
var _previous_compression_m: float = 0.0


func _ready() -> void:
	target_position = Vector3.DOWN * (suspension_travel_m + wheel_radius_m)
	var body: CollisionObject3D = get_parent() as CollisionObject3D
	if body != null:
		add_exception(body)


## Calcule et applique la force de suspension. À appeler avant `apply_tire_forces`.
func apply_suspension(body: RigidBody3D, delta: float) -> void:
	is_grounded = is_colliding()
	if not is_grounded:
		normal_force_n = 0.0
		_previous_compression_m = 0.0
		_place_visual(suspension_travel_m)
		return
	var hit_distance_m: float = global_position.distance_to(get_collision_point())
	var compression_m: float = clampf(suspension_travel_m + wheel_radius_m - hit_distance_m,
			0.0, suspension_travel_m)
	var compression_speed_mps: float = (compression_m - _previous_compression_m) / delta
	_previous_compression_m = compression_m
	normal_force_n = maxf(0.0, spring_stiffness_n_per_m * compression_m
			+ damping_n_per_mps * compression_speed_mps)
	body.apply_force(global_basis.y * normal_force_n, get_collision_point() - body.global_position)
	_place_visual(hit_distance_m - wheel_radius_m)


## Applique les forces du pneu au point de contact : traction et freinage dans l'axe, adhérence sur le côté.
func apply_tire_forces(body: RigidBody3D, mass_share_kg: float, delta: float) -> void:
	if not is_grounded:
		return
	var contact_offset: Vector3 = get_collision_point() - body.global_position
	var contact_velocity: Vector3 = body.linear_velocity + body.angular_velocity.cross(contact_offset)
	var forward: Vector3 = -global_basis.z
	var side: Vector3 = global_basis.x
	var forward_speed_mps: float = contact_velocity.dot(forward)
	var longitudinal_n: float = drive_force_n \
			- _compute_braking_force_n(forward_speed_mps, mass_share_kg, delta)
	var lateral_n: float = -contact_velocity.dot(side) * mass_share_kg / delta \
			* lateral_stiffness * lateral_grip_factor
	var tire_force: Vector3 = _limit_to_friction(forward * longitudinal_n + side * lateral_n)
	body.apply_force(tire_force, contact_offset)
	_spin_visual(forward_speed_mps, delta)


## Le frein ne peut qu'arrêter la roue, jamais la faire repartir dans l'autre sens.
func _compute_braking_force_n(forward_speed_mps: float, mass_share_kg: float, delta: float) -> float:
	var stopping_force_n: float = absf(forward_speed_mps) * mass_share_kg / delta
	return signf(forward_speed_mps) * minf(brake_force_n, stopping_force_n)


## Le pneu ne peut pas transmettre plus que ce que permet le frottement (cercle d'adhérence).
func _limit_to_friction(tire_force: Vector3) -> Vector3:
	var max_force_n: float = tire_friction_coefficient * surface_grip_factor * normal_force_n
	if tire_force.length() <= max_force_n:
		return tire_force
	return tire_force.normalized() * max_force_n


func _place_visual(center_depth_m: float) -> void:
	if wheel_visual == null:
		return
	wheel_visual.position.y = -center_depth_m


func _spin_visual(forward_speed_mps: float, delta: float) -> void:
	if wheel_visual == null:
		return
	wheel_visual.rotation.x -= forward_speed_mps / wheel_radius_m * delta
