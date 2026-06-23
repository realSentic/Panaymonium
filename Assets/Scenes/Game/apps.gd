extends Control

@onready var app1 = $"1/App1"
@onready var app2 = $"2/App2"
@onready var app3 = $"3/App3"

var window_manager: Node

func _ready() -> void:
	window_manager = get_tree().get_first_node_in_group("window_manager")

func _on_app_1_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		$"../EMailScreen".visible = true

func _on_e_mail_close_button_pressed() -> void:
	$"../EMailScreen".visible = false

func _on_app_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		$"../InternetScreen".visible = true
		
func _on_internet_close_button_pressed() -> void:
	$"../InternetScreen".visible = false
		
func _on_app_3_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		print("App 1 double clicked")
		

		
func _on_app_1_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(app1, "position", Vector2(0.0, -0.8), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(app1, "modulate", Color("a3ffffff"), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_app_1_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(app1, "position", Vector2(0.0, 0.0), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(app1, "modulate", Color("ffffffff"), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

func _on_app_2_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(app2, "position", Vector2(6.0, -0.8), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(app2, "modulate", Color("a3ffffff"), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_app_2_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(app2, "position", Vector2(6.0, 0.0), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(app2, "modulate", Color("ffffffff"), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

func _on_app_3_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(app3, "position", Vector2(1.0, -5.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(app3, "modulate", Color("a3ffffff"), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_app_3_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(app3, "position", Vector2(1.0, -4.0), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(app3, "modulate", Color("ffffffff"), 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
