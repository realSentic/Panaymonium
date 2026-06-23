extends Interactable

var has_interacted = false

# @onready var label = $"../Label"
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
	$BellRing.play()
	
