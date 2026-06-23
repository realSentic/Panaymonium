extends Control

@onready var homepage_screen = $HomepageScreen
@onready var nointernet_screen = $NoInternetScreen
@onready var input = $HomepageScreen/LineEdit

func _on_visibility_changed() -> void:
	if visible:
		homepage_screen.visible = true
		nointernet_screen.visible = false
		input.text = ""

func _on_button_pressed() -> void:
	if input.text == "":
		return
	homepage_screen.visible = false
	nointernet_screen.visible = true

func _on_internet_close_button_pressed() -> void:
	self.visible = false


func _on_texture_button_pressed() -> void:
	if input.text == "":
		return
	homepage_screen.visible = false
	nointernet_screen.visible = true
