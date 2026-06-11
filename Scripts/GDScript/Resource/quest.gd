class_name Quest
extends Resource

signal task_completed(task_id: String)
signal quest_completed(quest: Quest)

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""

var tasks: Dictionary = {}   # task_id -> { "label": String, "done": bool }
var is_complete: bool = false

func add_task(task_id: String, label: String) -> void:
	tasks[task_id] = { "label": label, "done": false }

func complete_task(task_id: String) -> void:
	if not tasks.has(task_id):
		push_warning("Quest '%s': unknown task '%s'" % [id, task_id])
		return
	if tasks[task_id]["done"]:
		return  # already done

	tasks[task_id]["done"] = true
	emit_signal("task_completed", task_id)

	# Check if all tasks are finished
	if tasks.values().all(func(t): return t["done"]):
		is_complete = true
		emit_signal("quest_completed", self)
