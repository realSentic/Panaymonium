extends Label

@onready var inventory_node = $"../../Inventory"
var current_tween: Tween
var interrupted: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	visible = not inventory_node.inventory_is_opened

func set_objective(new_text: String) -> void:
	interrupted = true
	if current_tween:
		current_tween.kill()
	text = ""
	scale = Vector2(1.0, 1.0)
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	await get_tree().create_timer(0.1).timeout  # ← small delay
	text = "Objective:\n%s" % new_text
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 1.0, 0.5)

func play_complete_animation() -> void:
	interrupted = false
	if current_tween:
		current_tween.kill()
	text = "Objective Complete!"
	modulate = Color.YELLOW
	modulate.a = 0
	scale = Vector2(1.2, 1.2)
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	current_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2.5).timeout
	if interrupted:
		return  # ← removed modulate = Color.WHITE here
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await current_tween.finished
	# ← removed modulate = Color.WHITE here too
