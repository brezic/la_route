class_name PlayerInteractor
extends RayCast3D
## Rayon partant du regard du joueur : détecte la zone interactive visée et déclenche l'interaction.

## Texte à afficher (vide si rien n'est visé).
signal prompt_changed(prompt_text: String)

## Le nœud transmis aux zones interactives (le joueur).
@export var interactor: Node

var _current_target: InteractableComponent = null


func _physics_process(_delta: float) -> void:
	var target: InteractableComponent = get_collider() as InteractableComponent if is_colliding() else null
	if target == _current_target:
		return
	_current_target = target
	prompt_changed.emit(_build_prompt(target))


func _unhandled_input(event: InputEvent) -> void:
	if _current_target == null or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	_current_target.interact(interactor)


func _notification(what: int) -> void:
	# Quand le joueur est désactivé (en voiture), on efface l'invite.
	if what == NOTIFICATION_DISABLED and _current_target != null:
		_current_target = null
		prompt_changed.emit("")


func _build_prompt(target: InteractableComponent) -> String:
	if target == null:
		return ""
	return "[%s] %s" % [InputHints.get_action_key_label("interact"), tr(target.prompt_key)]
