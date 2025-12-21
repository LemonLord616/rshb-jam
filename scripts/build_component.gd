extends Node3D
class_name ViewerBuildComponent

@export var viewer: Viewer
@export var item_database: ItemDatabase
@export var grid_map: GridMap

var _is_building: bool = false
var _is_removing: bool = false
var _shift_pressed: bool = false
var _last_grid_pos: Vector3i = Vector3i(-999, -999, -999)

func _on_build(switch: bool) -> void:
	_is_building = switch
	if not _is_building:
		_last_grid_pos = Vector3i(-999, -999, -999)
	if _is_building and _is_removing:
		_is_building = false
		_is_removing = false
	if _is_building:
		_place_item()

func _on_remove(switch: bool) -> void:
	_is_removing = switch
	if not _is_removing:
		_last_grid_pos = Vector3i(-999, -999, -999)
	if _is_building and _is_removing:
		_is_building = false
		_is_removing = false
	if _is_removing:
		_remove_item()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_SHIFT:
		_shift_pressed = event.pressed
	
	if event is InputEventMouseMotion:
		if _is_building:
			_place_item()
		if _is_removing:
			_remove_item()

func _place_item() -> void:
	var mesh_id = item_database.get_selected_item().get("mesh_id", -1)
	if mesh_id == -1:
		return
	
	var result = viewer.camera._raycast_under_mouse()
	if not result:
		return
	
	var grid_pos: Vector3i = grid_map.local_to_map(grid_map.to_local(result.position))
	
	if _shift_pressed:
		_draw_orthogonal_line(grid_pos, mesh_id)
	else:
		_draw_continuous_line(grid_pos, mesh_id)

func _remove_item() -> void:
	var result = viewer.camera._raycast_under_mouse()
	if not result:
		return
	
	var grid_pos: Vector3i = grid_map.local_to_map(grid_map.to_local(result.position))
	
	_draw_brush(grid_pos, GridMap.INVALID_CELL_ITEM)

func _draw_continuous_line(end_pos: Vector3i, item_id: int) -> void:
	var start_pos = _last_grid_pos
	if start_pos == Vector3i(-999, -999, -999):
		start_pos = end_pos
	
	var dir = end_pos - start_pos
	if abs(dir.x) >= abs(dir.y) and abs(dir.x) >= abs(dir.z):
		dir = Vector3i(sign(dir.x), 0, 0) * abs(dir.x)
	elif abs(dir.y) >= abs(dir.z):
		dir = Vector3i(0, sign(dir.y), 0) * abs(dir.y)
	else:
		dir = Vector3i(0, 0, sign(dir.z)) * abs(dir.z)
	
	var step = dir.sign()
	var distance = dir.length()
	for i in range(int(distance) + 1):
		var pos = start_pos + step * i
		grid_map.set_cell_item(pos, item_id)
	
	_last_grid_pos = end_pos

func _draw_orthogonal_line(end_pos: Vector3i, item_id: int) -> void:
	if _last_grid_pos == Vector3i(-999, -999, -999):
		_last_grid_pos = end_pos
		return
	
	var dir = end_pos - _last_grid_pos
	var length: int
	
	if abs(dir.x) >= abs(dir.y) and abs(dir.x) >= abs(dir.z):
		length = abs(dir.x)
		for i in range(length + 1):
			var pos = _last_grid_pos + Vector3i(i * sign(dir.x), 0, 0)
			grid_map.set_cell_item(pos, item_id)
	elif abs(dir.y) >= abs(dir.z):
		length = abs(dir.y)
		for i in range(length + 1):
			var pos = _last_grid_pos + Vector3i(0, i * sign(dir.y), 0)
			grid_map.set_cell_item(pos, item_id)
	else:
		length = abs(dir.z)
		for i in range(length + 1):
			var pos = _last_grid_pos + Vector3i(0, 0, i * sign(dir.z))
			grid_map.set_cell_item(pos, item_id)

func _draw_brush(center_pos: Vector3i, item_id: int) -> void:
	for x in range(-1, 2):
		for y in range(-1, 2):
			for z in range(-1, 2):
				var brush_pos = center_pos + Vector3i(x, y, z)
				grid_map.set_cell_item(brush_pos, item_id)
