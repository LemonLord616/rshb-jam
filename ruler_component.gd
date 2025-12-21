extends Node3D
class_name RulerComponent

@export var viewer: Viewer
@export var input_mode_manager: InputModeManager
@export var dot_color: Color = Color(1, 0, 0) # red
@export var line_color: Color = Color(0, 1, 0) # green

var _has_a := false
var _has_b := false
var _a: Vector3
var _b: Vector3

@onready var _mesh := ImmediateMesh.new()
@onready var _mesh_instance := MeshInstance3D.new()

func _ready() -> void:
	_mesh_instance.mesh = _mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1, 1, 1)
	_mesh_instance.material_override = mat
	add_child(_mesh_instance)
	_clear()

func _input(event: InputEvent) -> void:
	if not input_mode_manager.is_ruler():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_set_point_from_click()

func _set_point_from_click() -> void:
	var hit := viewer.camera._raycast_under_mouse()
	if not hit:
		return

	var pos: Vector3 = hit.position

	if not _has_a:
		_has_a = true
		_has_b = false
		_a = pos
	elif not _has_b:
		_has_b = true
		_b = pos
	else:
		# third click: restart
		_has_a = true
		_has_b = false
		_a = pos

	_update_geometry()

func _update_geometry() -> void:
	_mesh.clear_surfaces()

	# draw dot at A
	if _has_a:
		_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		_mesh.surface_set_color(dot_color)
		var up := Vector3.UP * 0.25
		var right := Vector3.RIGHT * 0.25
		# vertical cross
		_mesh.surface_add_vertex(_a - up)
		_mesh.surface_add_vertex(_a + up)
		# horizontal cross
		_mesh.surface_add_vertex(_a - right)
		_mesh.surface_add_vertex(_a + right)
		_mesh.surface_end()

	# draw dot at B + line A-B
	if _has_a and _has_b:
		# dot at B
		_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		_mesh.surface_set_color(dot_color)
		var up2 := Vector3.UP * 0.25
		var right2 := Vector3.RIGHT * 0.25
		_mesh.surface_add_vertex(_b - up2)
		_mesh.surface_add_vertex(_b + up2)
		_mesh.surface_add_vertex(_b - right2)
		_mesh.surface_add_vertex(_b + right2)
		_mesh.surface_end()

		# line A -> B
		_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		_mesh.surface_set_color(line_color)
		_mesh.surface_add_vertex(_a)
		_mesh.surface_add_vertex(_b)
		_mesh.surface_end()

		# distance: pure Pythagoras
		var dist := _a.distance_to(_b)
		print("RULER: distance = ", dist)

func _clear() -> void:
	_has_a = false
	_has_b = false
	_mesh.clear_surfaces()
