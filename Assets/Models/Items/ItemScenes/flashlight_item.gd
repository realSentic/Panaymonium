extends HoldableItem

@onready var light: SpotLight3D = $Light

var is_on: bool = true

func on_equip() -> void:
	light.visible = is_on

func on_unequip() -> void:
	light.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_flashlight"):
		is_on = !is_on
		light.visible = is_on
