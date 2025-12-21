extends Node
class_name InputModeManager

enum Mode { FREE, BUILD, RULER }

signal mode_changed(new_mode: Mode)

var mode: Mode = Mode.FREE:
	set(value):
		if mode == value:
			return
		mode = value
		mode_changed.emit(mode)

signal drag_switch(bool)
signal rotation_switch(bool)
signal build_switch(bool)
signal remove_switch(bool)
signal zoom(int)

func is_building_mode() -> bool:
	return mode == Mode.BUILD

func is_free_look() -> bool:
	return mode == Mode.FREE

func is_ruler() -> bool:
	return mode == Mode.RULER

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:
				_toggle_build_free()
			KEY_R:
				_toggle_ruler()
				
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_lmb(event)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_rmb(event)
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_mmb(event)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom.emit(-1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom.emit(1)

func _toggle_build_free() -> void:
	if mode == Mode.FREE:
		mode = Mode.BUILD
	else:
		mode = Mode.FREE

func _toggle_ruler() -> void:
	if mode == Mode.RULER:
		mode = Mode.FREE
	else:
		mode = Mode.RULER

func _lmb(event: InputEventMouseButton) -> void:
	if mode == Mode.FREE:
		if event.is_pressed():
			drag_switch.emit(true)
		elif event.is_released():
			drag_switch.emit(false)
	elif mode == Mode.BUILD:
		if event.is_pressed():
			build_switch.emit(true)
		elif event.is_released():
			build_switch.emit(false)
	
func _rmb(event: InputEventMouseButton) -> void:
	if mode == Mode.BUILD:
		if event.is_pressed():
			remove_switch.emit(true)
		elif event.is_released():
			remove_switch.emit(false)		

func _mmb(event: InputEventMouseButton) -> void:
	if event.is_pressed():
		rotation_switch.emit(true)
	elif event.is_released():
		rotation_switch.emit(false)
