extends Button

var computer_node

func _ready() -> void:
	computer_node = get_tree().get_first_node_in_group("computer_node")

func _on_pressed() -> void:
	if computer_node:
		computer_node._close_computer()
