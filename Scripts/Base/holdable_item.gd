class_name HoldableItem
extends Node3D

@export var item_id: String = ""

# Called when player equips this item
func on_equip() -> void:
	pass  # override in each item if needed

# Called when player unequips this item
func on_unequip() -> void:
	pass  # override in each item if needed
