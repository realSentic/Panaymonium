extends Node

@onready var inventory_menu = $"../InventoryUI/Inventory"
@onready var crosshair = $"../First Person View/Crosshair"
@onready var inventory_open_sfx = $"../SFX/InventoryOpen"
var inventory_is_opened = false

func _process(d):
	if Input.is_action_just_pressed("e") and not Global.is_interacting:
		inventory_menu.visible = !inventory_menu.visible
		inventory_is_opened = !inventory_is_opened
		
		if inventory_menu.visible:
			inventory_open_sfx.play()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			crosshair.visible = false
		else:
			inventory_open_sfx.play()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			crosshair.visible = true
