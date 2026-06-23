extends Interactable

var has_interacted = false
var cutscene_ended = false
var in_computer = false

@onready var interact_texture = $"InteractTexture"
@onready var computer_screen = $"../ComputerUI/ComputerScreen"

func _ready():
	interact_texture.visible = false
	computer_screen.visible = false
	computer_screen.modulate.a = 0.0

func show_prompt():
	interact_texture.visible = true

func hide_prompt():
	interact_texture.visible = false

func interact() -> void:
	if has_interacted:
		return
	has_interacted = true
	_play_cutscene()

func _open_computer() -> void:
	in_computer = true
	computer_screen.visible = true
	computer_screen.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(computer_screen, "modulate:a", 1.0, 0.7)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.is_interacting = true

func _close_computer() -> void:
	in_computer = false
	var tween = create_tween()
	tween.tween_property(computer_screen, "modulate:a", 0.0, 0.5)
	await tween.finished
	computer_screen.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.is_interacting = false
	has_interacted = false

func _play_cutscene() -> void:
	var quest = QuestManager.get_quest("open_pc")
	if quest != null:
		if not quest.quest_completed.is_connected(_on_quest_done):
			quest.quest_completed.connect(_on_quest_done)
		QuestManager.complete_task("open_pc", "task_1")
		await get_tree().create_timer(1.5).timeout
		_open_computer()
	else:
		print("Quest open_pc not started yet")

func _on_quest_done(quest: Quest) -> void:
	get_tree().get_first_node_in_group("objective_label").play_complete_animation()
