extends Area3D

@onready var label = $"../../View/Label"
@onready var VL1 = $"../../Voice Lines/VL1"
@onready var player = get_tree().get_first_node_in_group("player")
var in_area = false


func _on_body_entered(body: Node3D) -> void:
	if body == player:
		in_area = true


func _on_body_exited(body: Node3D) -> void:
	if body == player:
		in_area = false
		
func _process(d):
	if Input.is_action_just_pressed("e") and in_area:
		label.visible = true
		label.text = "Find the first key."
		VL1.play()
		await get_tree().create_timer(2.5).timeout
		label.visible = false
		label.text = ""
