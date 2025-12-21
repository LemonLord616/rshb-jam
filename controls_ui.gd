extends CanvasLayer
class_name ControlsUI

@export var input_mode_manager: InputModeManager
@onready var controls_label: Label = $ControlsLabel

func _ready() -> void:
	input_mode_manager.mode_changed.connect(_on_mode_changed)
	_on_mode_changed(input_mode_manager.mode) # init text

func _on_mode_changed(new_mode: InputModeManager.Mode) -> void:
	var text := """
F - change mode (Free / Build)
R - toggle ruler

Free look:
• LMB - drag camera

Building:
• LMB - build object
• Shift + LMB - build straight line
• RMB - remove object

Ruler:
• MMB - drag to measure

General:
• WASD - move camera
• MMB - rotate camera (when not in ruler)
• Scroll - Zoom in/out
"""
	match new_mode:
		InputModeManager.Mode.BUILD:
			text += "\n[BUILD MODE]"
		InputModeManager.Mode.RULER:
			text += "\n[RULER MODE]"
		_:
			text += "\n[FREE LOOK]"

	controls_label.text = text
