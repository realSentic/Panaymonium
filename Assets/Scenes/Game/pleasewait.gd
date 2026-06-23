extends Label

var dot_states := ["Please wait.", "Please wait..", "Please wait..."]
var current_index := 0
var timer := 0.0
@export var interval := 0.5  # seconds between each state

func _ready() -> void:
	text = dot_states[0]

func _process(delta: float) -> void:
	timer += delta
	if timer >= interval:
		timer = 0.0
		current_index = (current_index + 1) % dot_states.size()
		text = dot_states[current_index]
