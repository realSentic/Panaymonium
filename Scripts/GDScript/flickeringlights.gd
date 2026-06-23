extends SpotLight3D

@export var min_interval: float = 3.0
@export var max_interval: float = 8.0
@export var flicker_duration: float = 0.08
@export var min_flickers: int = 1
@export var max_flickers: int = 3
@export var dim_energy: float = 0.0

var base_energy: float

func _ready() -> void:
	base_energy = light_energy
	_schedule_next_flicker()

func _schedule_next_flicker() -> void:
	var wait_time = randf_range(min_interval, max_interval)
	await get_tree().create_timer(wait_time).timeout
	_do_flicker()

func _do_flicker() -> void:
	var flicker_count = randi_range(min_flickers, max_flickers)
	for i in range(flicker_count):
		light_energy = dim_energy
		await get_tree().create_timer(flicker_duration).timeout
		light_energy = base_energy
		await get_tree().create_timer(flicker_duration * 0.5).timeout
	_schedule_next_flicker()
