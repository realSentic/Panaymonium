# quest_manager.gd  — add as an Autoload named "QuestManager"
extends Node

signal quest_added(quest: Quest)

var _quests: Dictionary = {}   # quest_id -> Quest

func add_quest(quest: Quest) -> void:
	_quests[quest.id] = quest
	emit_signal("quest_added", quest)
	print("[Quest] Started: %s" % quest.title)

func complete_task(quest_id: String, task_id: String) -> void:
	if not _quests.has(quest_id):
		push_warning("QuestManager: unknown quest '%s'" % quest_id)
		return
	_quests[quest_id].complete_task(task_id)

func get_quest(quest_id: String) -> Quest:
	return _quests.get(quest_id, null)

func is_quest_complete(quest_id: String) -> bool:
	var q = get_quest(quest_id)
	return q.is_complete if q else false
