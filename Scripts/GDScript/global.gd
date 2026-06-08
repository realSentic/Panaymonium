extends Node
var is_interacting = false
var inventory = []
var item_db = {}
signal inventory_changed(item_id: String)

func _ready():
	var file = FileAccess.open("res://Scripts/JSON/items.json", FileAccess.READ)
	item_db = JSON.parse_string(file.get_as_text())
	file.close()

func add_item(item_id: String) -> void:
	inventory.append(item_id)
	inventory_changed.emit(item_id)
