extends Node

const ITEMS: Dictionary = {
	"flashlight": preload("res://Assets/Models/Items/ItemScenes/FlashlightItem.tscn"),
	# add more here
}

func get_scene(item_id: String) -> PackedScene:
	if not ITEMS.has(item_id):
		push_warning("ItemRegistry: no item registered with id '%s'" % item_id)
		return null
	return ITEMS[item_id]

func is_registered(item_id: String) -> bool:
	return ITEMS.has(item_id)
