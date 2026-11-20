class_name Dashboard
extends Node3D
## Tableau de bord diégétique : écoute les signaux du véhicule et met à jour les compteurs.
## Il ne lit jamais l'état du véhicule directement.

@export var vehicle: VehicleController
@export var fuel_tank: FuelTankComponent
@export var engine_temperature: EngineTemperatureComponent
@export var speed_needle: GaugeNeedle
@export var fuel_needle: GaugeNeedle
@export var temperature_needle: GaugeNeedle
@export var overheat_light: WarningLight
@export var fuel_readout: Label3D


func _ready() -> void:
	vehicle.speed_changed.connect(speed_needle.set_value)
	fuel_tank.fuel_changed.connect(_on_fuel_changed)
	engine_temperature.temperature_changed.connect(temperature_needle.set_value)
	engine_temperature.overheating_changed.connect(overheat_light.set_lit)
	_on_fuel_changed(fuel_tank.current_liters, fuel_tank.capacity_liters)


func _on_fuel_changed(current_liters: float, capacity_liters: float) -> void:
	fuel_needle.set_value(current_liters / capacity_liters if capacity_liters > 0.0 else 0.0)
	fuel_readout.text = "%.2f L" % current_liters
