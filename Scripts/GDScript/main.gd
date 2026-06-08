extends Node3D
@onready var fade = $"First Person View/Fade"
@onready var label = $View/Label2
@onready var subtitle = $View/Subtitle
@onready var dim_bg = $"First Person View/Dim"
@onready var main_voiceline_1 = $"Voice Lines/VLM1"
@onready var main_voiceline_2 = $"Voice Lines/VLM2"
@onready var texture_rect = $"First Person View/TextureRect"
@onready var objective_label = $View/Objective
var keyboard_bg = preload("res://Assets/Pictures/UI/WASD.webp")
var mouse_bg = preload("res://Assets/Pictures/UI/MOUSE.webp")
var voiceline_text = ["They said this place has been closed for decades.", "I can see why."]
var num = 0
signal tutorial_end

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	PickupManager.item_label = $View/ItemLabel
	PickupManager.dimmed_bg = $"First Person View/Dim"
	play_tutorial()

func play_tutorial():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	texture_rect.visible = true
	texture_rect.texture = keyboard_bg

func _on_next_pressed() -> void:
	num += 1
	if num == 1:
		texture_rect.texture = mouse_bg
	elif num == 2:
		texture_rect.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		tutorial_end.emit()
		play_other()
		label.text = "Act 1: Weaving"
		label.visible = true
		var tween = create_tween()
		tween.tween_property(fade, "modulate:a", 0, 3)
		tween.parallel().tween_property(label, "modulate:a", 1, 3)
		await get_tree().create_timer(4, false).timeout
		var tween2 = create_tween()
		tween2.tween_property(label, "modulate:a", 0, 1)
		await tween2.finished
		fade.visible = false
		label.visible = false

func play_other():
	await get_tree().create_timer(2.0, false).timeout
	subtitle.visible = false
	subtitle.modulate.a = 0
	await play_voiceline(main_voiceline_1, voiceline_text[0])
	await play_voiceline(main_voiceline_2, voiceline_text[1])
	var tween_end = create_tween()
	tween_end.tween_property(subtitle, "modulate:a", 0, 0.5)
	await tween_end.finished
	subtitle.visible = false
	_on_voicelines_finished()

func play_voiceline(voiceline: AudioStreamPlayer, text: String):
	if subtitle.modulate.a > 0:
		var fade_out = create_tween()
		fade_out.tween_property(subtitle, "modulate:a", 0, 0.3)
		await fade_out.finished
	subtitle.visible = true
	subtitle.text = text
	var fade_in = create_tween()
	fade_in.tween_property(subtitle, "modulate:a", 1, 0.3)
	await fade_in.finished
	voiceline.play()
	await get_tree().create_timer(voiceline.stream.get_length(), false).timeout

func _on_voicelines_finished():
	objective_label.visible = true
	var tween = create_tween()
	tween.tween_property(objective_label, "position", Vector2(17.0, 273.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(objective_label, "position", Vector2(13.0, 273.0), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
