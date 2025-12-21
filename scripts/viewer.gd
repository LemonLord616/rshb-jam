extends CharacterBody3D
class_name Viewer

@export var camera : ViewerCamera
@export var move_component : ViewerMoveComponent
@export var build_component: ViewerBuildComponent

@export var input_mode_manager: InputModeManager

func _ready() -> void:
	input_mode_manager.drag_switch.connect(move_component._on_drag)
	input_mode_manager.rotation_switch.connect(move_component._on_rotate)
	input_mode_manager.zoom.connect(move_component._zoom)
	input_mode_manager.build_switch.connect(build_component._on_build)
	input_mode_manager.remove_switch.connect(build_component._on_remove)

func _physics_process(_delta: float) -> void:
	velocity = velocity.lerp(Vector3.ZERO, 0.1)
	move_component.wasd_process()
	move_and_slide()
	position = position.clamp(Vector3(-60, 0, -60), Vector3(60, 60, 60))
