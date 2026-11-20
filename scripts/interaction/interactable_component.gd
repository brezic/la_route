class_name InteractableComponent
extends Area3D
## Zone avec laquelle le joueur peut interagir (porte, objet…). Ne fait rien elle-même : elle émet un signal.

signal interacted(interactor: Node)

## Clé de traduction du texte affiché quand le joueur vise la zone.
@export var prompt_key: String = ""


func interact(interactor: Node) -> void:
	interacted.emit(interactor)
