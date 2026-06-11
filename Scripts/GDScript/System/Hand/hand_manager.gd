class_name HandManager
extends Node3D

signal item_equipped(item_id: String)
signal item_unequipped

@export var hold_point: Marker3D

var current_item: HoldableItem = null
var current_item_id: String = ""

# Breathing
var base_position: Vector3
var breathe_speed = 1.2
var breathe_strength = 0.02

func _ready() -> void:
	base_position = position

func _process(delta: float) -> void:
	# Breathing
	var breathe = sin(Time.get_ticks_msec() * 0.001 * breathe_speed) * breathe_strength
	position.y = base_position.y + breathe

func equip(item_id: String) -> void:
	print("equip called: ", item_id)
	if current_item_id == item_id:
		print("already holding")
		return
	_clear_hand()
	var scene: PackedScene = ItemRegistry.get_scene(item_id)
	print("scene: ", scene)
	if scene == null:
		return
	var instance = scene.instantiate()
	print("is HoldableItem: ", instance is HoldableItem)
	if not instance is HoldableItem:
		push_warning("HandManager: '%s' scene root is not a HoldableItem" % item_id)
		instance.queue_free()
		return
	print("holdpoint: ", hold_point)
	hold_point.add_child(instance)
	current_item = instance as HoldableItem
	current_item_id = item_id
	current_item.on_equip()
	emit_signal("item_equipped", item_id)

func unequip() -> void:
	_clear_hand()
	emit_signal("item_unequipped")

func get_current_item_id() -> String:
	return current_item_id

func is_holding(item_id: String) -> bool:
	return current_item_id == item_id

func has_item() -> bool:
	return current_item != null

func _clear_hand() -> void:
	if current_item:
		current_item.on_unequip()
		current_item.queue_free()
		current_item = null
		current_item_id = ""
