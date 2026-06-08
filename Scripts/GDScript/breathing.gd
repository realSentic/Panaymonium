extends Node3D

var base_position: Vector3
var breathe_speed = 1.2
var breathe_strength = 0.02

func _ready():
	base_position = position

func _process(delta: float) -> void:
	var breathe = sin(Time.get_ticks_msec() * 0.001 * breathe_speed) * breathe_strength
	position.y = base_position.y + breathe
