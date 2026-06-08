extends Area3D

@export var item_name : String
@export var item_display_text : String

var in_area := false
var has_interacted := false
var player

@onready var label = $"../../../View/InteractionLabel"
@onready var itemlabel = $"../../../View/ItemLabel"
@onready var item_layer = $"../../../View/Flashlight"
@onready var item_preview = $"../../../View/Flashlight/SubViewportContainer"
@onready var dimmed_bg = $"../../../First Person View/Dim"
@onready var pickup_sfx = $"../../../SFX/ChestOpen"

func _ready():
	player = get_tree().get_first_node_in_group("player")

	item_layer.visible = false
	dimmed_bg.visible = false

	item_preview.modulate.a = 0
	itemlabel.modulate.a = 0
	dimmed_bg.modulate.a = 0


func _process(_delta):
	if in_area and Input.is_action_just_pressed("e") and !Global.is_interacting:
		interact()


func interact():
	Global.is_interacting = true
	has_interacted = true

	add_item()

	label.visible = false

	if pickup_sfx:
		pickup_sfx.play()

	await show_pickup_popup()

	Global.is_interacting = false

	queue_free() # removes pickup object


func add_item():
	Global.inventory.append(item_name)

	var inv_menu = get_tree().get_first_node_in_group("inventory_menu")

	if inv_menu:
		inv_menu.add_item(item_name)


func show_pickup_popup():
	itemlabel.text = item_display_text

	itemlabel.visible = true
	itemlabel.modulate.a = 1.0

	item_layer.visible = true
	dimmed_bg.visible = true

	var tween = create_tween()
	tween.tween_property(item_preview, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(dimmed_bg, "modulate:a", 1.0, 0.5)

	await tween.finished
	await get_tree().create_timer(2.0).timeout

	var tween2 = create_tween()
	tween2.tween_property(item_preview, "modulate:a", 0.0, 1.5)
	tween2.parallel().tween_property(itemlabel, "modulate:a", 0.0, 1.5)
	tween2.parallel().tween_property(dimmed_bg, "modulate:a", 0.0, 1.5)

	await tween2.finished

	itemlabel.visible = false
	item_layer.visible = false
	dimmed_bg.visible = false


func _on_body_entered(body):
	if body == player and !has_interacted and !Global.is_interacting:
		in_area = true
		label.visible = true
		label.text = "Press E to Interact."


func _on_body_exited(body):
	if body == player:
		in_area = false
		label.visible = false
