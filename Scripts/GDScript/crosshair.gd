extends CanvasLayer

@onready var crosshair = $Crosshair

func _process(delta: float) -> void:
	crosshair.visible = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
