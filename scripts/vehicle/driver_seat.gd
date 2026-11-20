class_name DriverSeat
extends Node3D
## Place du conducteur : fait monter et descendre le joueur, et donne ou retire les commandes du véhicule.

signal driver_entered(driver: PlayerController)
signal driver_exited(driver: PlayerController)
## Texte d'aide à afficher pendant la conduite (vide hors du véhicule).
signal prompt_changed(prompt_text: String)

@export var vehicle_input: VehicleInput
@export var engine: EngineComponent
@export var door: InteractableComponent
@export var seat_camera: Camera3D
## Endroit où le joueur réapparaît en descendant.
@export var exit_point: Marker3D

var _driver: PlayerController = null


func _ready() -> void:
	door.interacted.connect(_on_door_interacted)


func _unhandled_input(event: InputEvent) -> void:
	if _driver == null or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	_exit_vehicle()


func is_occupied() -> bool:
	return _driver != null


func _on_door_interacted(interactor: Node) -> void:
	var player: PlayerController = interactor as PlayerController
	if player == null or is_occupied():
		return
	_enter_vehicle(player)


func _enter_vehicle(player: PlayerController) -> void:
	_driver = player
	player.set_controlled(false)
	seat_camera.make_current()
	vehicle_input.is_enabled = true
	driver_entered.emit(player)
	prompt_changed.emit("[%s] %s" % [InputHints.get_action_key_label("interact"), tr("INTERACT_EXIT_CAR")])


## En descendant, le joueur coupe le contact et le frein à main se serre.
func _exit_vehicle() -> void:
	var player: PlayerController = _driver
	_driver = null
	vehicle_input.is_enabled = false
	engine.stop()
	player.teleport_to(exit_point.global_transform)
	player.set_controlled(true)
	driver_exited.emit(player)
	prompt_changed.emit("")
