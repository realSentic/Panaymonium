extends Node3D

var spin_speed = 1.5

func _process(delta: float) -> void:
	rotate_y(delta * spin_speed)
