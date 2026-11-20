class_name BiomeData
extends Resource
## Données d'un biome : climat et adhérence du sol.

## Clé de traduction du nom du biome.
@export var display_name_key: String = ""
## Température de l'air (sans météo ni cycle jour/nuit en V0.1).
@export var ambient_celsius: float = 20.0
## Multiplicateur d'adhérence des pneus (1 = asphalte sec).
@export_range(0.0, 2.0) var grip_factor: float = 1.0
@export var ground_color: Color = Color("7a9a4e")
