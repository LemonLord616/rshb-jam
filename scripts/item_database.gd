extends Node
class_name ItemDatabase

@export var mesh_library: MeshLibrary

signal selected_item_id_changed(new_id: int)

var items: Dictionary = {}
var selected_item_id: int = 0:
	set(value):
		selected_item_id = value
		selected_item_id_changed.emit(value)


func _ready() -> void:
	items.clear()
	for item_id in mesh_library.get_item_list():
		items[item_id] = {
			"name": mesh_library.get_item_name(item_id),
			"mesh_id": item_id
		}

func get_item_name(id: int) -> String:
	return items.get(id, {}).get("name", "Unknown")

func get_mesh_id(id: int) -> int:
	return items.get(id, {}).get("mesh_id", -1)

func get_selected_item() -> Dictionary:
	return items.get(selected_item_id, {})
