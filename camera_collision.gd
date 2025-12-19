extends CharacterBody3D
class_name CameraCollision

@export var camera : Camera3D
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 5.0  # Скорость зума

var _anchor_point: Vector3
var _drag: bool = false
var _rotating: bool = false
var _mouse_delta: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	velocity = velocity.lerp(Vector3.ZERO, 0.1)
	
	# LMB: движение по поверхности
	if Input.is_action_just_pressed("LMB"):
		var current_point := _raycast_under_mouse()
		if current_point:
			_anchor_point = current_point.position
			_drag = true
	if Input.is_action_pressed("LMB") and _drag:
		var current_point := _raycast_under_mouse()
		if current_point:
			var delta_move: Vector3 = current_point.position - _anchor_point
			velocity = -10 * Vector3(delta_move.x, 0, delta_move.z)
	if Input.is_action_just_released("LMB"):
		_drag = false
	
	# MMB: поворот
	if Input.is_action_just_pressed("MMB"):
		_rotating = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_released("MMB"):
		_rotating = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if _rotating:
		_apply_rotation()
	
	move_and_slide()
	position = position.clamp(Vector3(-60, 0, -60), Vector3(60, 60, 60))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _rotating:
		_mouse_delta = event.relative
	
	# Колесико: скорость вперед/назад
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			velocity += -camera.global_transform.basis.z * zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			velocity += camera.global_transform.basis.z * zoom_speed

func _apply_rotation():
	rotate_y(-_mouse_delta.x * rotation_speed)
	camera.rotate_x(-_mouse_delta.y * rotation_speed)
	camera.rotation.x = clamp(camera.rotation.x, -PI/2 + 0.1, PI/2 - 0.1)
	_mouse_delta = Vector2.ZERO

# Остальные функции без изменений
func _raycast_under_mouse() -> Dictionary:
	var ray_length := 1000
	var mouse_position := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse_position)
	var to := from + camera.project_ray_normal(mouse_position) * ray_length
	var result := _intersect_space_state(from, to)
	return result

func _intersect_space_state(from: Vector3, to: Vector3) -> Dictionary:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	return result

func _intersect_y_line(y: float, from: Vector3, to: Vector3) -> Variant:
	var plane := Plane.PLANE_XZ
	plane.d = y
	var intersection = plane.intersects_ray(from, to)
	return intersection
