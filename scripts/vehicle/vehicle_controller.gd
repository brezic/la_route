class_name VehicleController
extends RigidBody3D
## Orchestre le véhicule : lit les pédales, pilote le moteur, braque et répartit les forces sur les roues.
## Boîte automatique simplifiée : à l'arrêt, la pédale de frein enclenche la marche arrière.

signal speed_changed(speed_kmh: float)

const MPS_TO_KMH: float = 3.6
const WATTS_PER_KW: float = 1000.0
## En dessous de cette vitesse, on n'applique plus les résistances (évite les tremblements à l'arrêt).
const MIN_RESISTANCE_SPEED_MPS: float = 0.1

@export_group("Composants")
@export var engine: EngineComponent
@export var engine_temperature: EngineTemperatureComponent
@export var vehicle_input: VehicleInput
@export var biome: BiomeData

@export_group("Transmission")
@export var max_traction_force_n: float = 4500.0
## Vitesse plancher pour le calcul force = puissance / vitesse (évite une force infinie à l'arrêt).
@export var min_traction_speed_mps: float = 1.0
@export var max_reverse_speed_mps: float = 5.0
## Sous cette vitesse, la pédale de frein passe la marche arrière.
@export var reverse_engage_speed_mps: float = 0.5

@export_group("Freinage")
@export var max_brake_force_n: float = 7000.0
@export var handbrake_force_n: float = 2500.0
## Adhérence latérale restante des roues arrière frein à main serré (permet de faire glisser l'arrière).
@export_range(0.0, 1.0) var handbrake_lateral_grip: float = 0.35

@export_group("Direction")
@export var max_steer_angle_degrees: float = 32.0
@export var high_speed_steer_angle_degrees: float = 6.0
## Vitesse à laquelle l'angle de braquage atteint son minimum.
@export var steer_reduction_speed_mps: float = 40.0
@export var steer_rate_degrees_per_second: float = 90.0

@export_group("Résistances")
## 0,5 × densité de l'air × Cx × surface frontale.
@export var aerodynamic_drag_n_per_mps2: float = 0.4
@export var rolling_resistance_n: float = 125.0

var _wheels: Array[RaycastWheel] = []
var _steer_angle_degrees: float = 0.0


## Commande de pédales après interprétation par la boîte automatique.
class PedalCommand:
	## Positif : marche avant. Négatif : marche arrière.
	var throttle: float = 0.0
	var brake: float = 0.0


func _ready() -> void:
	for child in get_children():
		if child is RaycastWheel:
			_wheels.append(child)
	for wheel in _wheels:
		wheel.surface_grip_factor = biome.grip_factor
	engine_temperature.reset_to(biome.ambient_celsius)


func _physics_process(delta: float) -> void:
	var forward_speed_mps: float = get_forward_speed_mps()
	var pedals: PedalCommand = _resolve_pedals(vehicle_input.get_accelerate(),
			vehicle_input.get_brake(), forward_speed_mps)
	var output_power_kw: float = _update_engine(delta, absf(pedals.throttle), forward_speed_mps)
	_update_steering(delta, forward_speed_mps)
	var traction_n: float = _compute_traction_force_n(pedals, output_power_kw, forward_speed_mps)
	_assign_wheel_commands(pedals, traction_n)
	_apply_wheel_forces(delta)
	_apply_resistances()
	speed_changed.emit(absf(forward_speed_mps) * MPS_TO_KMH)


## Vitesse dans l'axe du véhicule (négative en marche arrière).
func get_forward_speed_mps() -> float:
	return linear_velocity.dot(-global_basis.z)


func _resolve_pedals(accelerate: float, brake: float, forward_speed_mps: float) -> PedalCommand:
	var command: PedalCommand = PedalCommand.new()
	if accelerate > 0.0 and forward_speed_mps < -reverse_engage_speed_mps:
		# On recule encore : l'accélérateur sert d'abord à freiner.
		command.brake = accelerate
	elif brake > 0.0 and forward_speed_mps < reverse_engage_speed_mps:
		# Quasi à l'arrêt : le frein enclenche la marche arrière.
		command.throttle = -brake
	else:
		command.throttle = accelerate
		command.brake = brake
	return command


## Démarre le moteur à l'accélération, consomme l'essence et fait évoluer la température.
func _update_engine(delta: float, throttle_amount: float, forward_speed_mps: float) -> float:
	if throttle_amount > 0.0 and not engine.is_running:
		engine.try_start()
	var output_power_kw: float = engine.get_output_power_kw(throttle_amount)
	engine.run_step(delta, output_power_kw)
	engine_temperature.simulate(delta, output_power_kw, engine.is_running,
			biome.ambient_celsius, absf(forward_speed_mps))
	return output_power_kw


## Le braquage maximal diminue avec la vitesse, et le volant tourne à vitesse limitée.
func _update_steering(delta: float, forward_speed_mps: float) -> void:
	var speed_ratio: float = clampf(absf(forward_speed_mps) / steer_reduction_speed_mps, 0.0, 1.0)
	var max_angle_degrees: float = lerpf(max_steer_angle_degrees, high_speed_steer_angle_degrees, speed_ratio)
	var target_degrees: float = vehicle_input.get_steer() * max_angle_degrees
	_steer_angle_degrees = move_toward(_steer_angle_degrees, target_degrees,
			steer_rate_degrees_per_second * delta)


## Force de traction totale : limitée par l'adhérence à basse vitesse, par la puissance ensuite.
func _compute_traction_force_n(pedals: PedalCommand, output_power_kw: float,
		forward_speed_mps: float) -> float:
	if pedals.throttle < 0.0 and forward_speed_mps < -max_reverse_speed_mps:
		return 0.0
	var power_limited_n: float = output_power_kw * WATTS_PER_KW \
			/ maxf(absf(forward_speed_mps), min_traction_speed_mps)
	var traction_n: float = minf(max_traction_force_n * absf(pedals.throttle), power_limited_n)
	return traction_n * signf(pedals.throttle)


func _assign_wheel_commands(pedals: PedalCommand, traction_n: float) -> void:
	var driven_wheel_count: int = _wheels.filter(func(wheel: RaycastWheel) -> bool: return wheel.is_driven).size()
	var is_handbrake_engaged: bool = vehicle_input.is_handbrake_engaged()
	for wheel in _wheels:
		var handbrake_active: bool = is_handbrake_engaged and wheel.has_handbrake
		wheel.drive_force_n = traction_n / driven_wheel_count if wheel.is_driven else 0.0
		wheel.brake_force_n = max_brake_force_n * pedals.brake / _wheels.size()
		wheel.brake_force_n += handbrake_force_n if handbrake_active else 0.0
		wheel.lateral_grip_factor = handbrake_lateral_grip if handbrake_active else 1.0
		if wheel.is_steering:
			wheel.rotation.y = deg_to_rad(_steer_angle_degrees)


func _apply_wheel_forces(delta: float) -> void:
	var mass_share_kg: float = mass / _wheels.size()
	for wheel in _wheels:
		wheel.apply_suspension(self, delta)
	for wheel in _wheels:
		wheel.apply_tire_forces(self, mass_share_kg, delta)


## Traînée aérodynamique et résistance au roulement, opposées au mouvement.
func _apply_resistances() -> void:
	var speed_mps: float = linear_velocity.length()
	if speed_mps < MIN_RESISTANCE_SPEED_MPS:
		return
	var resistance_n: float = aerodynamic_drag_n_per_mps2 * speed_mps * speed_mps + rolling_resistance_n
	apply_central_force(-linear_velocity / speed_mps * resistance_n)
