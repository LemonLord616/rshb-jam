extends Camera3D
class_name MovingCamera

var _anchor_point: Vector3

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("LMB"):
		_anchor_point = _raycast_under_mouse()
		print(_anchor_point)
	if Input.is_action_pressed("LMB"):
		var current_point := _raycast_under_mouse()
		var delta_move := current_point - _anchor_point
		position -= Vector3(delta_move.x, 0, delta_move.z)

func _raycast_under_mouse() -> Vector3:
	var ray_length := 1000
	var mouse_position := get_viewport().get_mouse_position()
	var from := project_ray_origin(mouse_position)
	var to := from + project_ray_normal(mouse_position) * ray_length
	var result := _intersect_space_state(from, to)
	if result:
		return result.position
	var intersection = _intersect_y_line(_anchor_point.y, from, to)
	if intersection:
		return intersection
	return to

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
