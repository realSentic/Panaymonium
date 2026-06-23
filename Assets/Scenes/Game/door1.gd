extends Interactable

var has_interacted = false
@export var item_name: String = ""
@onready var interact_texture = $InteractTexture

var voiceline_text = [
	"The door is locked.",
	"There must be a way inside.",
	"Maybe the computer could help."
]

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
	if item_name != "":
		PickupManager.show_item(item_name)
	else:
		play_lines()

func play_lines() -> void:
	var reception_room = get_tree().get_first_node_in_group("reception_room")
	var subtitle = reception_room.get_node("View/Subtitle")
	await play_voiceline(subtitle, null, voiceline_text[0])
	await play_voiceline(subtitle, null, voiceline_text[1])
	await play_voiceline(subtitle, null, voiceline_text[2])
	var tween_end = create_tween()
	tween_end.tween_property(subtitle, "modulate:a", 0, 0.5)
	await tween_end.finished
	subtitle.visible = false

func play_voiceline(subtitle: Label, voiceline, text: String) -> void:
	if subtitle.modulate.a > 0:
		var fade_out = create_tween()
		fade_out.tween_property(subtitle, "modulate:a", 0, 0.3)
		await fade_out.finished
	subtitle.visible = true
	subtitle.text = text
	var fade_in = create_tween()
	fade_in.tween_property(subtitle, "modulate:a", 1, 0.3)
	await fade_in.finished
	if voiceline != null:
		voiceline.play()
		await get_tree().create_timer(voiceline.stream.get_length(), false).timeout
	else:
		# placeholder: just show subtitle for 2.5 seconds
		await get_tree().create_timer(2.5, false).timeout
		has_interacted = false
