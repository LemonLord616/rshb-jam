extends Camera3D
class_name ViewerCamera

func _raycast_under_mouse() -> Dictionary:
	var ray_length := 1000
	var mouse_position := get_viewport().get_mouse_position()
	var from := project_ray_origin(mouse_position)
	var to := from + project_ray_normal(mouse_position) * ray_length
	var result := _intersect_space_state(from, to)
	return result

func _intersect_space_state(from: Vector3, to: Vector3) -> Dictionary:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	return result

#func _intersect_y_line(y: float, from: Vector3, to: Vector3) -> Variant:
	#var plane := Plane.PLANE_XZ
	#plane.d = y
	#var intersection = plane.intersects_ray(from, to)
	#return intersection
