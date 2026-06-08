extends Area3D
var in_area = false
var has_interacted = false
var player
var voiceline_text = [
	"This mask...",
	"I don't like the way it's looking at me."
]
@onready var interaction_label = $"../../../View/InteractionLabel"
@onready var subtitle = $"../../../View/Subtitle"
@onready var voiceline_1 = $"../../../Voice Lines/VLM3"
@onready var voiceline_2 = $"../../../Voice Lines/VLM4"

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body):
	if body == player and not has_interacted and not Global.is_interacting:
		in_area = true
		interaction_label.visible = true
		interaction_label.text = "Press E to Inspect"

func _on_body_exited(body):
	if body == player:
		in_area = false
		interaction_label.visible = false

func _process(delta):
	if in_area and Input.is_action_just_pressed("e") and not has_interacted and not Global.is_interacting:
		has_interacted = true
		Global.is_interacting = true
		interaction_label.visible = false
		await play_voiceline(voiceline_1, voiceline_text[0])
		await play_voiceline(voiceline_2, voiceline_text[1])
		var tween = create_tween()
		tween.tween_property(subtitle, "modulate:a", 0.0, 0.5)
		await tween.finished
		subtitle.visible = false
		_on_voicelines_finished()

func play_voiceline(voiceline: AudioStreamPlayer, text: String):
	if subtitle.modulate.a > 0:
		var fade_out = create_tween()
		fade_out.tween_property(subtitle, "modulate:a", 0.0, 0.3)
		await fade_out.finished
	subtitle.visible = true
	subtitle.text = text
	var fade_in = create_tween()
	fade_in.tween_property(subtitle, "modulate:a", 1.0, 0.3)
	await fade_in.finished
	voiceline.play()
	await get_tree().create_timer(voiceline.stream.get_length()).timeout

func _on_voicelines_finished():
	has_interacted = false
	Global.is_interacting = false
