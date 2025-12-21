extends Control
class_name MeshSelector

@export var item_database: ItemDatabase
@export var button: Button
@onready var popup_menu: PopupMenu = $PopupMenu

var _selected_item_id: int = 0:
	set(value):
		_selected_item_id = value
		item_database.selected_item_id = value
		button.text = item_database.get_item_name(value) + " ▼"

func _ready() -> void:
	popup_menu.hide_on_item_selection = false
	_populate_menu()
	button.pressed.connect(_on_button_pressed)
	button.text = item_database.get_item_name(_selected_item_id) + " ▼"

func _populate_menu() -> void:
	popup_menu.clear()
	for item_id in item_database.items.keys():
		var item_name = item_database.get_item_name(item_id)
		popup_menu.add_item(item_name, item_id)
	popup_menu.id_pressed.connect(_on_item_selected)

func _on_button_pressed() -> void:
	var button_global_rect = button.get_global_rect()
	var popup_rect = Rect2i(button_global_rect.position, button_global_rect.size)
	popup_menu.popup(popup_rect)

func _on_item_selected(id: int) -> void:
	_selected_item_id = id
	popup_menu.hide()
