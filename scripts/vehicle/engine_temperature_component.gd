class_name EngineTemperatureComponent
extends Node
## Température du moteur : chauffe avec la charge, refroidie par le radiateur et l'air.
## Au-delà du seuil de surchauffe, la puissance disponible diminue.

signal temperature_changed(celsius: float)
signal overheating_changed(is_overheating: bool)

@export_group("Seuils")
## Le thermostat s'ouvre et le radiateur commence à refroidir.
@export var thermostat_open_celsius: float = 90.0
## Le voyant s'allume et la puissance commence à baisser.
@export var overheat_celsius: float = 110.0
## Le voyant s'éteint une fois redescendu sous ce seuil (hystérésis).
@export var overheat_recovery_celsius: float = 105.0
## Température à laquelle la puissance atteint son minimum.
@export var critical_celsius: float = 125.0
## Part de puissance restante à la température critique.
@export_range(0.0, 1.0) var min_power_factor: float = 0.4

@export_group("Thermique")
## Énergie nécessaire pour élever le moteur de 1 °C (valeur réduite pour le gameplay).
@export var heat_capacity_kj_per_celsius: float = 8.0
## Part de la puissance mécanique transformée en chaleur dans le liquide.
@export var heat_ratio_per_engine_kw: float = 0.35
## Chaleur produite au ralenti.
@export var idle_heat_kw: float = 2.0
## Pertes naturelles du bloc moteur vers l'air ambiant.
@export var natural_loss_kw_per_celsius: float = 0.03
## Efficacité du radiateur à l'arrêt (ventilateur seul).
@export var radiator_base_kw_per_celsius: float = 0.3
## Gain d'efficacité du radiateur par m/s de vitesse (air qui traverse la calandre).
@export var radiator_airflow_kw_per_celsius_per_mps: float = 0.012

var current_celsius: float = 20.0
var is_overheating: bool = false


## Place le moteur à une température donnée (ex : température ambiante au départ).
func reset_to(celsius: float) -> void:
	current_celsius = celsius
	temperature_changed.emit(current_celsius)
	_update_overheat_state()


## Avance la simulation thermique d'un pas de temps.
func simulate(delta: float, engine_power_kw: float, is_running: bool,
		ambient_celsius: float, airspeed_mps: float) -> void:
	var heat_input_kw: float = _compute_heat_input_kw(engine_power_kw, is_running)
	var heat_loss_kw: float = _compute_heat_loss_kw(is_running, ambient_celsius, airspeed_mps)
	current_celsius += (heat_input_kw - heat_loss_kw) * delta / heat_capacity_kj_per_celsius
	temperature_changed.emit(current_celsius)
	_update_overheat_state()


## Multiplicateur de puissance (1 = normal, diminue en surchauffe).
func get_power_factor() -> float:
	if current_celsius <= overheat_celsius:
		return 1.0
	var overheat_progress: float = inverse_lerp(overheat_celsius, critical_celsius, current_celsius)
	return lerpf(1.0, min_power_factor, clampf(overheat_progress, 0.0, 1.0))


func _compute_heat_input_kw(engine_power_kw: float, is_running: bool) -> float:
	if not is_running:
		return 0.0
	return idle_heat_kw + engine_power_kw * heat_ratio_per_engine_kw


func _compute_heat_loss_kw(is_running: bool, ambient_celsius: float, airspeed_mps: float) -> float:
	var natural_loss_kw: float = natural_loss_kw_per_celsius * (current_celsius - ambient_celsius)
	# La pompe à eau ne tourne que moteur allumé : sans elle, le radiateur ne sert à rien.
	if not is_running or current_celsius <= thermostat_open_celsius:
		return natural_loss_kw
	var radiator_efficiency: float = radiator_base_kw_per_celsius \
			+ radiator_airflow_kw_per_celsius_per_mps * airspeed_mps
	return natural_loss_kw + radiator_efficiency * (current_celsius - thermostat_open_celsius)


func _update_overheat_state() -> void:
	var should_overheat: bool = is_overheating
	if current_celsius >= overheat_celsius:
		should_overheat = true
	elif current_celsius <= overheat_recovery_celsius:
		should_overheat = false
	if should_overheat == is_overheating:
		return
	is_overheating = should_overheat
	overheating_changed.emit(is_overheating)
