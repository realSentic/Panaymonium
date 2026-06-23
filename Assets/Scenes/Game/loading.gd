@tool
extends Control

@export var radius := 20.0
@export var line_width := 4.0
@export var spin_speed := 4.0  # radians per second
@export var arc_length := PI * 1.5  # how much of the circle is drawn

var rotation_angle := 0.0

func _process(delta: float) -> void:
	rotation_angle += spin_speed * delta
	queue_redraw()

func _draw() -> void:
	var center = size / 2
	draw_arc(center, radius, rotation_angle, rotation_angle + arc_length, 32, Color.WHITE, line_width, true)
