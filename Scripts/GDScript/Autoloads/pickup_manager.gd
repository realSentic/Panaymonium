extends Node
var busy := false
var item_label: Label
var dimmed_bg: CanvasItem

func show_item(item_id: String) -> void:
	if busy:
		return
	if item_label == null or dimmed_bg == null:
		push_error("PickupManager references not set!")
		return
	if !Global.item_db.has(item_id):
		push_error("Item '%s' not found in item_db!" % item_id)
		return
	busy = true
	Global.is_interacting = true
	Global.add_item(item_id)
	var item_data = Global.item_db[item_id]
	item_label.text = item_data["name"] + " Acquired."
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	var preview_container = SubViewportContainer.new()
	preview_container.stretch = true
	preview_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(preview_container)
	get_tree().root.add_child(canvas_layer)
	if item_data.has("preview") and item_data["preview"] != "":
		var preview_scene = load(item_data["preview"])
		if preview_scene:
			var sub_viewport = SubViewport.new()
			sub_viewport.transparent_bg = true
			sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
			sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			var preview = preview_scene.instantiate()
			sub_viewport.add_child(preview)
			preview_container.add_child(sub_viewport)
	item_label.visible = true
	canvas_layer.visible = true
	dimmed_bg.visible = true
	item_label.modulate.a = 0.0
	preview_container.modulate.a = 0.0
	dimmed_bg.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(item_label, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(preview_container, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(dimmed_bg, "modulate:a", 1.0, 0.5)
	await tween.finished
	await get_tree().create_timer(2.0).timeout
	var tween2 = create_tween()
	tween2.tween_property(item_label, "modulate:a", 0.0, 1.5)
	tween2.parallel().tween_property(preview_container, "modulate:a", 0.0, 1.5)
	tween2.parallel().tween_property(dimmed_bg, "modulate:a", 0.0, 1.5)
	await tween2.finished
	item_label.visible = false
	dimmed_bg.visible = false
	canvas_layer.queue_free()
	Global.is_interacting = false
	busy = false
