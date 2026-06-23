extends Node2D

@onready var input = $LoginScreen/LineEdit
@onready var input_btn = $LoginScreen/EnterButton
var password = "4719"

func _on_enter_button_pressed() -> void:
	if input.text == password:
		$LoadingScreen.visible = true
		$LoginScreen.visible = false
		await get_tree().create_timer(5.0).timeout
		$HomeScreen.visible = true
		$LoadingScreen.visible = false
		print("CORRECT!")
	else:
		$SFX/WrongPassword.play()
		$LoginScreen/WrongPasswordLabel.visible = true
		print("WRONG!")


func _on_app_1_mouse_exited() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	pass # Replace with function body.
