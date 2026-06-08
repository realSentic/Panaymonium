extends Node3D

@onready var model = $Flashlight

var spinning = false

func open_chest():
	spinning = true

func _process(delta):
	if spinning:
		model.rotate_y(delta * 2.0)  # adjust speed with the number
