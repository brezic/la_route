class_name InputHints
extends RefCounted
## Retrouve le nom de la touche associée à une action, selon la disposition du clavier (AZERTY, QWERTY…).

const HEADLESS_DISPLAY_SERVER: String = "headless"


static func get_action_key_label(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		var key_event: InputEventKey = event as InputEventKey
		if key_event == null:
			continue
		return OS.get_keycode_string(_to_layout_keycode(key_event.physical_keycode))
	return String(action)


## Sans fenêtre (tests), la disposition du clavier est inconnue : on garde la position QWERTY.
static func _to_layout_keycode(physical_keycode: Key) -> Key:
	if DisplayServer.get_name() == HEADLESS_DISPLAY_SERVER:
		return physical_keycode
	return DisplayServer.keyboard_get_keycode_from_physical(physical_keycode)
