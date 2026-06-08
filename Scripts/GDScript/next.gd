extends Button

var blink_speed = 1.5
@onready var main = $"../.."

func _ready():
	_blink()
	main.tutorial_end.connect(_hide_button)

func _blink():
	while true:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, blink_speed)
		tween.tween_property(self, "modulate:a", 1.0, blink_speed)
		await tween.finished
		
func _hide_button():
	visible = false
