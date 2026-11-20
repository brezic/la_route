class_name FuelTankComponent
extends Node
## Réservoir d'essence : stocke et délivre du carburant, en litres.

signal fuel_changed(current_liters: float, capacity_liters: float)
signal fuel_depleted

## Capacité totale du réservoir.
@export var capacity_liters: float = 50.0
## Niveau au lancement de la partie (le réservoir n'est jamais plein au départ).
@export var initial_liters: float = 0.5

var current_liters: float = 0.0


func _ready() -> void:
	set_fuel_level(initial_liters)


## Fixe le niveau d'essence, borné entre 0 et la capacité.
func set_fuel_level(liters: float) -> void:
	current_liters = clampf(liters, 0.0, capacity_liters)
	fuel_changed.emit(current_liters, capacity_liters)


## Retire jusqu'à `amount_liters` du réservoir et renvoie la quantité réellement fournie.
func draw_fuel(amount_liters: float) -> float:
	if amount_liters <= 0.0 or is_empty():
		return 0.0
	var delivered_liters: float = minf(amount_liters, current_liters)
	current_liters -= delivered_liters
	fuel_changed.emit(current_liters, capacity_liters)
	if is_empty():
		fuel_depleted.emit()
	return delivered_liters


func is_empty() -> bool:
	return current_liters <= 0.0


## Niveau entre 0 (vide) et 1 (plein), pour la jauge.
func get_fill_ratio() -> float:
	if capacity_liters <= 0.0:
		return 0.0
	return current_liters / capacity_liters
