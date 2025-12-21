extends Node3D
class_name ViewerMoveComponent

@export var viewer: Viewer

@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 5.0
@export var move_speed: float = 10.0

var _anchor_point: Vector3
var _drag: bool = false
var _rotating: bool = false
var _dir_move := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _rotating:
		_apply_rotation(event.relative)
	if event is InputEventMouseMotion and _drag:
		_apply_drag()
	#if event is InputEventKey:
		#_wasd_movement(event)
#
#func _wasd_movement(event: InputEventKey) -> void:
	#if event.echo: return
	#match event.physical_keycode:
		#KEY_W: _dir_move.y = -1.0 if event.pressed else 0.0
		#KEY_A: _dir_move.x = -1.0 if event.pressed else 0.0
		#KEY_S: _dir_move.y =  1.0 if event.pressed else 0.0
		#KEY_D: _dir_move.x =  1.0 if event.pressed else 0.0
		#_: return
#
	#if _dir_move.length() > 1.0:
		#_dir_move = _dir_move.normalized()

func _apply_rotation(mouse_delta: Vector2) -> void:
	viewer.rotate_y(-mouse_delta.x * rotation_speed)
	viewer.camera.rotate_x(-mouse_delta.y * rotation_speed)
	viewer.camera.rotation.x = clamp(viewer.camera.rotation.x, -PI/2 + 0.1, PI/2 - 0.1)

func _apply_drag() -> void:
	var current_point := viewer.camera._raycast_under_mouse()
	if current_point:
		var delta_move: Vector3 = current_point.position - _anchor_point
		viewer.velocity = -10 * Vector3(delta_move.x, 0, delta_move.z)

func wasd_process() -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var speed = move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed /= 2
	var cam_forward = -viewer.camera.global_transform.basis.z
	var cam_right = viewer.camera.global_transform.basis.x
	var move_dir = - (cam_forward * input_dir.y) + (cam_right * input_dir.x)
	viewer.velocity += move_dir.normalized() * speed

func _on_drag(switch: bool) -> void:
	if not switch:
		_drag = false
		return
	var current_point := viewer.camera._raycast_under_mouse()
	if current_point:
		_anchor_point = current_point.position
		_drag = true

func _on_rotate(switch: bool) -> void:
	if switch:
		_rotating = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		_rotating = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _zoom(_sign: int):
	viewer.velocity += _sign * viewer.camera.global_transform.basis.z * zoom_speed
