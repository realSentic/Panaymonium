extends Node2D
var last_selected_index := -1
@onready var menu_sfx = $Fwoom
var left_tween: Tween
var right_tween: Tween
var left_hovered := false
var right_hovered := false

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
