extends Node

@onready var pause_menu = $"../First Person View/PauseMenu"

func _process(d):
	if Input.is_action_just_pressed("esc"):
		pause_menu.visible = !pause_menu.visible
		
		if pause_menu.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
