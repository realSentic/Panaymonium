extends Node2D

@export var app_window_scene: PackedScene
@export var taskbar: HBoxContainer

var open_windows := {}
var z_counter := 10

func open_app(app_id: String, app_name: String, content_scene: PackedScene) -> void:
	if open_windows.has(app_id):
		var win = open_windows[app_id]
		win.visible = true
		_focus_window(win)
		return

	var window = app_window_scene.instantiate()
	window.app_name = app_name
	add_child(window)

	if content_scene:
		var content = content_scene.instantiate()
		window.set_content(content)

	window.closed.connect(func(w): _on_window_closed(app_id, w))
	window.minimized.connect(func(w): _on_window_minimized(app_id, w))

	open_windows[app_id] = window
	_add_taskbar_button(app_id, app_name)
	_focus_window(window)

func _focus_window(window: Control) -> void:
	z_counter += 1
	window.z_index = z_counter

func _on_window_closed(app_id: String, window: Control) -> void:
	open_windows.erase(app_id)
	_remove_taskbar_button(app_id)

func _on_window_minimized(app_id: String, window: Control) -> void:
	pass

func _add_taskbar_button(app_id: String, app_name: String) -> void:
	var btn = Button.new()
	btn.name = "taskbar_" + app_id
	btn.text = app_name
	btn.pressed.connect(func(): _restore_app(app_id))
	taskbar.add_child(btn)

func _remove_taskbar_button(app_id: String) -> void:
	var btn = taskbar.get_node_or_null("taskbar_" + app_id)
	if btn:
		btn.queue_free()

func _restore_app(app_id: String) -> void:
	if open_windows.has(app_id):
		var win = open_windows[app_id]
		win.visible = true
		_focus_window(win)
