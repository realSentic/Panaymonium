extends Area3D

var player: CharacterBody3D = null
var in_area = false

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_body_entered(body: Node3D) -> void:
	if body == player:
		in_area = true
		
func _on_body_exited(body: Node3D) -> void:
	if body == player:
		in_area = false
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("e") and in_area == true:
		print("Hello")
