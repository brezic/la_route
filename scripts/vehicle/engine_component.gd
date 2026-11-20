class_name EngineComponent
extends Node
## Moteur thermique simplifié : démarre, consomme de l'essence et fournit de la puissance.

signal started
signal stopped
## Le moteur s'est arrêté seul (panne sèche).
signal stalled

const SECONDS_PER_HOUR: float = 3600.0

@export var fuel_tank: FuelTankComponent
@export var temperature: EngineTemperatureComponent
## Puissance maximale (citadine des années 80).
@export var max_power_kw: float = 45.0
## Consommation au ralenti.
@export var idle_consumption_liters_per_hour: float = 0.8
## Litres brûlés par kWh produit (rendement d'un petit moteur essence).
@export var specific_consumption_liters_per_kwh: float = 0.4

var is_running: bool = false


## Démarre le moteur s'il reste de l'essence. Renvoie vrai si le moteur tourne.
func try_start() -> bool:
	if is_running:
		return true
	if fuel_tank.is_empty():
		return false
	is_running = true
	started.emit()
	return true


func stop() -> void:
	if not is_running:
		return
	is_running = false
	stopped.emit()


## Puissance fournie pour une position d'accélérateur (0 à 1), réduite en surchauffe.
func get_output_power_kw(throttle: float) -> float:
	if not is_running:
		return 0.0
	return clampf(throttle, 0.0, 1.0) * max_power_kw * temperature.get_power_factor()


## Consomme l'essence d'un pas de temps et cale si le réservoir ne suit plus.
func run_step(delta: float, output_power_kw: float) -> void:
	if not is_running:
		return
	var needed_liters: float = compute_consumption_liters(delta, output_power_kw)
	var delivered_liters: float = fuel_tank.draw_fuel(needed_liters)
	if delivered_liters < needed_liters:
		_stall()


## Litres consommés pendant `delta` secondes à la puissance donnée.
func compute_consumption_liters(delta: float, output_power_kw: float) -> float:
	var liters_per_hour: float = idle_consumption_liters_per_hour \
			+ output_power_kw * specific_consumption_liters_per_kwh
	return liters_per_hour * delta / SECONDS_PER_HOUR


func _stall() -> void:
	is_running = false
	stalled.emit()
