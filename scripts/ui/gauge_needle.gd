class_name GaugeNeedle
extends Node3D
## Aiguille de compteur : tourne autour de son axe Z selon une valeur.

@export var min_value: float = 0.0
@export var max_value: float = 1.0
## Angle de l'aiguille à la valeur minimale (sens trigonométrique, 0 = vers la droite).
@export var min_angle_degrees: float = 225.0
@export var max_angle_degrees: float = -45.0


func _ready() -> void:
	set_value(min_value)


func set_value(value: float) -> void:
	var progress: float = clampf(inverse_lerp(min_value, max_value, value), 0.0, 1.0)
	rotation.z = deg_to_rad(lerpf(min_angle_degrees, max_angle_degrees, progress))
