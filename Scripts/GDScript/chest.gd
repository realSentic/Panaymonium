extends Interactable
var has_interacted = false
@export var item_name: String = "flashlight"
@onready var chest_sfx = $"../../../SFX/ChestOpen"
@onready var interact_texture = $"../InteractTexture"

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
	chest_sfx.play()
	PickupManager.show_item(item_name)
