extends Node3D
class_name PreviewComponent

@export var viewer: Viewer
@export var grid_map: GridMap
@export var item_database: ItemDatabase
@export var input_mode_manager: InputModeManager

var _preview_pos: Vector3i = Vector3i(-999, -999, -999)
var _preview_item_id: int = -1
var _object_placed := false

func _ready() -> void:
	_preview_item_id = item_database.selected_item_id
	item_database.selected_item_id_changed.connect(_on_selected_item_changed)
	input_mode_manager.build_switch.connect(_on_place)

func _on_place(switch: bool) -> void:
	if switch:
		_object_placed = true

func _process(_delta: float) -> void:
	if not input_mode_manager.is_building_mode():
		if _preview_pos != Vector3i(-999, -999, -999):
			_clear_preview()
		return

	
	var result = viewer.camera._raycast_under_mouse()
	if not result:
		if _preview_pos != Vector3i(-999, -999, -999):
			_clear_preview()
		return
	
	var grid_pos: Vector3i = grid_map.local_to_map(grid_map.to_local(result.position))
	
	if grid_pos != _preview_pos or item_database.selected_item_id != _preview_item_id:
		_clear_preview()
		if _is_tile_vacant(grid_pos):
			_place_preview(grid_pos)

func _place_preview(grid_pos: Vector3i) -> void:	
	_preview_pos = grid_pos
	_preview_item_id = item_database.selected_item_id
	var mesh_id = item_database.get_selected_item().get("mesh_id", -1)
	if mesh_id != -1:
		grid_map.set_cell_item(grid_pos, mesh_id)

func _clear_preview() -> void:
	if _object_placed:
		_object_placed = false
		return
	if _preview_pos != Vector3i(-999, -999, -999):
		grid_map.set_cell_item(_preview_pos, GridMap.INVALID_CELL_ITEM)
	_preview_pos = Vector3i(-999, -999, -999)
	_preview_item_id = -1

func _is_tile_vacant(pos: Vector3i) -> bool:
	return grid_map.get_cell_item(pos) == GridMap.INVALID_CELL_ITEM

func _on_selected_item_changed(new_id: int) -> void:
	_preview_item_id = new_id
	_clear_preview()
