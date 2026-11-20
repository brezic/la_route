class_name PlayerController
extends CharacterBody3D
## Joueur à pied, à la première personne : marcher, courir, regarder.

@export var walk_speed_mps: float = 3.0
@export var sprint_speed_mps: float = 6.0
## Vitesse à laquelle le joueur atteint sa vitesse cible (inertie au sol).
@export var ground_acceleration: float = 12.0
@export var mouse_sensitivity_radians_per_pixel: float = 0.0025
@export var max_pitch_degrees: float = 85.0

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D

var _gravity_mps2: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity_mps2 * delta
	var target_velocity: Vector3 = _compute_target_velocity()
	var blend: float = clampf(ground_acceleration * delta, 0.0, 1.0)
	velocity.x = lerpf(velocity.x, target_velocity.x, blend)
	velocity.z = lerpf(velocity.z, target_velocity.z, blend)
	move_and_slide()


## Active ou désactive le joueur à pied (désactivé pendant la conduite).
func set_controlled(is_controlled: bool) -> void:
	visible = is_controlled
	process_mode = Node.PROCESS_MODE_INHERIT if is_controlled else Node.PROCESS_MODE_DISABLED
	_collision_shape.set_deferred("disabled", not is_controlled)
	velocity = Vector3.ZERO
	if is_controlled:
		_camera.make_current()


## Place le joueur à un endroit en gardant son orientation vers une direction.
func teleport_to(target: Transform3D) -> void:
	global_position = target.origin
	rotation.y = target.basis.get_euler().y
	_head.rotation.x = 0.0


func _look(mouse_delta: Vector2) -> void:
	rotate_y(-mouse_delta.x * mouse_sensitivity_radians_per_pixel)
	var max_pitch: float = deg_to_rad(max_pitch_degrees)
	_head.rotation.x = clampf(_head.rotation.x - mouse_delta.y * mouse_sensitivity_radians_per_pixel,
			-max_pitch, max_pitch)


func _compute_target_velocity() -> Vector3:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = global_basis * Vector3(input_direction.x, 0.0, input_direction.y)
	var speed: float = sprint_speed_mps if Input.is_action_pressed("sprint") else walk_speed_mps
	return direction * speed
