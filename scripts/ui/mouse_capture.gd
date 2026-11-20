class_name MouseCapture
extends Node
## Capture la souris pendant le jeu. Échap la libère, un clic la reprend.
## Juste après la capture, le curseur est recentré : ce saut n'est pas un vrai mouvement, on l'ignore.

## Durée pendant laquelle les mouvements de souris sont ignorés après une capture.
@export var settle_milliseconds: int = 250

var _ignore_motion_until_msec: int = 0


func _ready() -> void:
	_capture()


func _notification(what: int) -> void:
	# Quand la fenêtre reprend le focus, le curseur peut aussi « sauter ».
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_start_settle_window()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Time.get_ticks_msec() < _ignore_motion_until_msec:
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		_capture()


func _capture() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_start_settle_window()


func _start_settle_window() -> void:
	_ignore_motion_until_msec = Time.get_ticks_msec() + settle_milliseconds
