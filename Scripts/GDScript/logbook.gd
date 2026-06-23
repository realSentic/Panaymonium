extends Interactable

var has_interacted = false
@onready var interact_texture = $"InteractTexture"

func _ready():
	interact_texture.visible = false

func show_prompt():
	interact_texture.visible = true

func hide_prompt():
	interact_texture.visible = false

func interact() -> void:
	if has_interacted:
		return
	has_interacted = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.is_interacting = true
	$CanvasLayer.visible = true

func _input(event: InputEvent) -> void:
	if $CanvasLayer.visible and event.is_action_pressed("ui_cancel"):
		$CanvasLayer.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.is_interacting = false
