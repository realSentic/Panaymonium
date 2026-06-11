extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body != get_tree().get_first_node_in_group("player"):
		return
	# Disconnect immediately as the very first thing
	body_entered.disconnect(_on_body_entered)
	set_deferred("monitoring", false)
	
	QuestManager.complete_task("reception_table", "reception_area")
	await get_tree().create_timer(3.0).timeout
	_start_next_quest()
	queue_free()

func _start_next_quest() -> void:
	var q = Quest.new()
	q.id = "open_pc"
	q.title = "Open the PC."
	q.description = "Open the Personal Computer."
	q.add_task("task_1", "Open the PC.")
	q.task_completed.connect(_on_task_done)
	q.quest_completed.connect(_on_quest_done)
	QuestManager.add_quest(q)
	get_tree().get_first_node_in_group("objective_label").set_objective(q.title)

func _on_task_done(task_id: String) -> void:
	print("Task completed: ", task_id)

func _on_quest_done(quest: Quest) -> void:
	get_tree().get_first_node_in_group("objective_label").play_complete_animation()
