class_name VehicleInput
extends Node
## Lit les commandes du conducteur. Renvoie des commandes neutres quand personne n'est au volant.

var is_enabled: bool = false


## Pédale d'accélérateur, de 0 à 1.
func get_accelerate() -> float:
	if not is_enabled:
		return 0.0
	return Input.get_action_strength("vehicle_accelerate")


## Pédale de frein (et marche arrière à l'arrêt), de 0 à 1.
func get_brake() -> float:
	if not is_enabled:
		return 0.0
	return Input.get_action_strength("vehicle_brake")


## Volant : positif vers la gauche, négatif vers la droite.
func get_steer() -> float:
	if not is_enabled:
		return 0.0
	return Input.get_axis("vehicle_steer_right", "vehicle_steer_left")


## Sans conducteur, le frein à main reste serré.
func is_handbrake_engaged() -> bool:
	if not is_enabled:
		return true
	return Input.is_action_pressed("vehicle_handbrake")
