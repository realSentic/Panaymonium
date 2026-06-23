extends Node2D

var last_selected_index := -1

@onready var menu_sfx = $Fwoom
@onready var click_sfx = $Click

var left_tween: Tween
var right_tween: Tween
var left_hovered := false
var right_hovered := false

var equipped_item_id: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.inventory_changed.connect(_on_inventory_changed)
	_setup_button_shader($HBoxContainer/Left)
	_setup_button_shader($HBoxContainer/Right)

func _setup_button_shader(button: TextureButton) -> void:
	button.texture_hover = button.texture_normal
	button.texture_pressed = button.texture_normal
	button.mouse_entered.connect(func(): _hover_button(button))
	button.mouse_exited.connect(func(): _unhover_button(button))

func _hover_button(button: TextureButton) -> void:
	if button == $HBoxContainer/Left:
		left_hovered = true
	else:
		right_hovered = true
	var t = _get_tween(button)
	t.tween_property(button, "modulate", Color(0.6, 0.0, 1.0, 1.0), 0.15)

func _unhover_button(button: TextureButton) -> void:
	if button == $HBoxContainer/Left:
		left_hovered = false
	else:
		right_hovered = false
	var t = _get_tween(button)
	t.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.15)

func flash_button(button: TextureButton) -> void:
	var is_hovered = left_hovered if button == $HBoxContainer/Left else right_hovered
	var end_color = Color(0.6, 0.0, 1.0, 1.0) if is_hovered else Color(1, 1, 1, 1)
	var t = _get_tween(button)
	t.tween_property(button, "modulate", Color(1.0, 0.5, 1.0, 1.0), 0.05)
	t.tween_property(button, "modulate", end_color, 0.3)

func _get_tween(button: TextureButton) -> Tween:
	if button == $HBoxContainer/Left:
		if left_tween:
			left_tween.kill()
		left_tween = create_tween()
		return left_tween
	else:
		if right_tween:
			right_tween.kill()
		right_tween = create_tween()
		return right_tween

func _process(delta: float) -> void:
	var carousel = $CarouselContainer
	var children = carousel.position_offset_node.get_children()
	if carousel.selected_index != last_selected_index:
		last_selected_index = carousel.selected_index
		if children.size() > 0 and last_selected_index < children.size():
			var selected_panel = children[last_selected_index]
			var item_id = selected_panel.get_meta("item_id")
			if Global.item_db.has(item_id):
				$"Item Name".text = Global.item_db[item_id]["name"]
		_update_use_button()
	for i in range(children.size()):
		var child = children[i]
		var tex_rect = child.get_child(0) if child.get_child_count() > 0 else null
		if tex_rect and tex_rect.material:
			var is_selected = i == carousel.selected_index
			tex_rect.material.set_shader_parameter("selected", is_selected)
			var dist = abs(i - carousel.selected_index)
			tex_rect.material.set_shader_parameter("brightness", 1.0 if is_selected else max(0.3, 1.0 - dist * 0.4))
			tex_rect.material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

func _on_inventory_changed(item_id: String) -> void:
	var item_data = Global.item_db[item_id]
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(40, 40)
	panel.size = Vector2(40, 40)
	panel.set_meta("item_id", item_id)
	var empty_style := StyleBoxEmpty.new()
	panel.add_theme_stylebox_override("panel", empty_style)
	var texture_rect := TextureRect.new()
	texture_rect.texture = load(item_data["icon"])
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var shader_material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform vec4 glow_color : source_color = vec4(0.6, 0.0, 1.0, 1.0);
uniform float glow_size : hint_range(0.0, 10.0) = 5.0;
uniform bool selected = false;
uniform float time = 0.0;
uniform float brightness : hint_range(0.0, 1.0) = 1.0;
uniform vec4 dim_color : source_color = vec4(0.2, 0.2, 0.2, 1.0);
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float fade = brightness;
	if (!selected) {
		tex.rgb = mix(dim_color.rgb, tex.rgb, brightness * 0.3);
	} else {
		float pulse = (sin(time * 3.0) * 0.5 + 0.5);
		fade = 0.7 + pulse * 0.3;
		tex.rgb *= fade;
	}
	COLOR = tex;
	if (selected) {
		float pulse = (sin(time * 3.0) * 0.5 + 0.5);
		vec2 ps = TEXTURE_PIXEL_SIZE * (glow_size + pulse * 2.0);
		float outline = texture(TEXTURE, UV + vec2(ps.x, 0.0)).a;
		outline += texture(TEXTURE, UV - vec2(ps.x, 0.0)).a;
		outline += texture(TEXTURE, UV + vec2(0.0, ps.y)).a;
		outline += texture(TEXTURE, UV - vec2(0.0, ps.y)).a;
		outline = clamp(outline, 0.0, 1.0);
		vec4 final_glow = glow_color * (0.5 + pulse * 0.5);
		COLOR = mix(COLOR, final_glow, outline * (1.0 - tex.a));
	}
}
"""
	shader_material.shader = shader
	texture_rect.material = shader_material
	panel.add_child(texture_rect)
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$CarouselContainer.position_offset_node.add_child(panel)
	var children = $CarouselContainer.position_offset_node.get_children()
	if children.size() == 1:
		$"Item Name".text = item_data["name"]

func _on_left_pressed() -> void:
	$CarouselContainer._left()
	flash_button($HBoxContainer/Left)
	if $CarouselContainer.position_offset_node.get_child_count() > 1:
		menu_sfx.play()

func _on_right_pressed() -> void:
	$CarouselContainer._right()
	flash_button($HBoxContainer/Right)
	if $CarouselContainer.position_offset_node.get_child_count() > 1:
		menu_sfx.play()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var child_count = $CarouselContainer.position_offset_node.get_child_count()
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$CarouselContainer._left()
				flash_button($HBoxContainer/Left)
				if child_count > 1:
					menu_sfx.play()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$CarouselContainer._right()
				flash_button($HBoxContainer/Right)
				if child_count > 1:
					menu_sfx.play()

func _on_use_pressed() -> void:
	click_sfx.play()
	var carousel = $CarouselContainer
	var children = carousel.position_offset_node.get_children()

	if children.size() == 0:
		return

	var selected_panel = children[carousel.selected_index]
	var item_id = selected_panel.get_meta("item_id")
	var item_data = Global.item_db[item_id]

	if item_data.has("readable") and item_data["readable"] != "":
		_show_readable(item_data["readable"])
		return

	if item_data.has("usable") and item_data["usable"] == false:
		return

	var found_player = get_tree().get_first_node_in_group("player")

	if equipped_item_id == item_id:
		equipped_item_id = ""
		if found_player:
			found_player.drop_item()
	else:
		equipped_item_id = item_id
		if found_player:
			found_player.use_item(item_id)

	_update_use_button()

func _show_readable(image_path: String) -> void:
	if Global.is_interacting:
		return  # prevent opening another readable while one is active

	self.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.is_interacting = true
	get_tree().paused = false

	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 20
	get_tree().root.add_child(canvas_layer)

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(bg)

	var padding := 60.0

	var tex_rect = TextureRect.new()
	tex_rect.texture = load(image_path)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	tex_rect.offset_left = padding
	tex_rect.offset_top = padding
	tex_rect.offset_right = -padding
	tex_rect.offset_bottom = -padding
	tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(tex_rect)

	bg.modulate.a = 0.0
	tex_rect.modulate.a = 0.0

	var hint_label = Label.new()
	hint_label.text = "Click anywhere to exit"
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.offset_top = -70
	hint_label.offset_bottom = -20
	hint_label.offset_left = 900
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(hint_label)
	hint_label.modulate.a = 0.0

	var close_btn = Button.new()
	close_btn.flat = true
	close_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(close_btn)

	var tween = get_tree().create_tween()
	tween.tween_property(bg, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(tex_rect, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(hint_label, "modulate:a", 1.0, 0.5)

	close_btn.pressed.connect(func():
		if not is_instance_valid(canvas_layer):
			return
		var tween2 = get_tree().create_tween()
		tween2.tween_property(bg, "modulate:a", 0.0, 0.5)
		tween2.parallel().tween_property(tex_rect, "modulate:a", 0.0, 0.5)
		tween2.parallel().tween_property(hint_label, "modulate:a", 0.0, 0.5)
		tween2.finished.connect(func():
			if is_instance_valid(canvas_layer):
				canvas_layer.queue_free()
			Global.is_interacting = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			self.visible = true
		)
	)

func _update_use_button() -> void:
	var carousel = $CarouselContainer
	var children = carousel.position_offset_node.get_children()

	if children.size() == 0:
		$HBoxContainer/Use.texture_normal = preload("res://Assets/Pictures/UI/use.png")
		return

	var selected_panel = children[carousel.selected_index]
	var item_id = selected_panel.get_meta("item_id")

	if item_id == equipped_item_id and equipped_item_id != "":
		$HBoxContainer/Use.texture_normal = preload("res://Assets/Pictures/UI/use_hover.png")
	else:
		$HBoxContainer/Use.texture_normal = preload("res://Assets/Pictures/UI/use.png")
