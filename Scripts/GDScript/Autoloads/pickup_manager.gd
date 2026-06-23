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
	get_tree().root.add_child(canvas_layer)

	var texture_rect = null

	if item_data.has("preview") and item_data["preview"] != "":
		var preview_scene = load(item_data["preview"])
		if preview_scene:
			var preview_node = preview_scene.instantiate()
			canvas_layer.add_child(preview_node)
			texture_rect = preview_node.get_node("TextureRect")

	item_label.visible = true
	dimmed_bg.visible = true
	item_label.modulate.a = 0.0
	dimmed_bg.modulate.a = 0.0
	if texture_rect != null:
		texture_rect.modulate.a = 0.0

	# Fade in
	var tween = get_tree().create_tween()
	tween.tween_property(item_label, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(dimmed_bg, "modulate:a", 1.0, 0.5)
	if texture_rect != null:
		tween.parallel().tween_property(texture_rect, "modulate:a", 1.0, 0.5)
	await tween.finished

	await get_tree().create_timer(2.0).timeout

	# Dissolve icon + fade out text simultaneously
	var exit_tween = get_tree().create_tween()
	exit_tween.tween_property(item_label, "modulate:a", 0.0, 1.0)
	exit_tween.parallel().tween_property(dimmed_bg, "modulate:a", 0.0, 1.0)
	if texture_rect != null:
		texture_rect.material.set_shader_parameter("dissolve_amount", 0.0)
		exit_tween.parallel().tween_property(texture_rect.material, "shader_parameter/dissolve_amount", 1.0, 1.0)
	await exit_tween.finished

	item_label.visible = false
	dimmed_bg.visible = false
	canvas_layer.queue_free()
	Global.is_interacting = false
	busy = false
