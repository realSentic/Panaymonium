extends Control

signal closed(window)
signal minimized(window)

@export var app_name := "App"

@onready var title_label = $TitleLabel
@onready var content_area = $ContentArea

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_label.text = app_name

func set_content(node: Control) -> void:
	for child in content_area.get_children():
		child.queue_free()
	content_area.add_child(node)
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_close_pressed() -> void:
	closed.emit(self)
	queue_free()

func _on_minimize_pressed() -> void:
	visible = false
	minimized.emit(self)
