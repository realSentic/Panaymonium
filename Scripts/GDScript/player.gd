extends CharacterBody3D

var SPEED = 3.0
const JUMP = 4.0
const SENSITIVITY = 0.001
const GRAVITY = 6.0

@onready var stamina = $"../View/ProgressBar"
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var light_sfx = $SFX/Flashlight
@onready var hand: HandManager = $Head/Camera3D/HandManager

var interaction_texture: Sprite3D
var stamina_value = 100.0
var stamina_tween: Tween
var can_sprint = true
var regen_timer: SceneTreeTimer

# Headbob
var headbob_speed = 6.0
var headbob_strength = 0.05
var headbob_time = 0.0
var camera_base_y: float

# Footsteps
var footstep_timer = 0.0
var footstep_interval = 0.4
var current_surface = "concrete"

@onready var FOOTSTEP_SOUNDS = {
	"wood": $FootstepSFX/WoodenFootstep,
	"grass": $FootstepSFX/GrassFootstep,
}

func _ready():
	add_to_group("player")
	camera_base_y = camera.position.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	interaction_texture = get_tree().get_first_node_in_group("interaction_texture")
	stamina.max_value = 100.0
	stamina.value = 100.0
	stamina.visible = false

func _set_stamina_visible(value: bool) -> void:
	if value:
		stamina.visible = true
	else:
		if not stamina.is_inventory_open():
			stamina.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	_do_raycast()
	_update_camera_feel(delta)
	_update_footsteps(delta)

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if Input.is_action_pressed("sprint") and is_on_floor() and can_sprint:
		var tween = create_tween()
		tween.tween_property(camera, "fov", 90.0, 0.2).set_ease(Tween.EASE_OUT)
		SPEED = 4.5
		_set_stamina_visible(true)
		regen_timer = null
		if stamina_tween:
			stamina_tween.kill()
		stamina_value = max(stamina_value - 20.0 * delta, 0.0)
		stamina.value = stamina_value
		if stamina_value <= 0.0:
			can_sprint = false
			SPEED = 3.0
			_start_regen_with_delay()

	if Input.is_action_just_released("sprint"):
		SPEED = 3.0
		var tween = create_tween()
		tween.tween_property(camera, "fov", 75.0, 0.2).set_ease(Tween.EASE_IN)
		if can_sprint:
			_start_regen_with_delay()

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = head.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()

func _update_camera_feel(delta: float) -> void:
	var is_moving = velocity.length() > 0.1 and is_on_floor()
	if is_moving:
		var speed_factor = velocity.length() / SPEED
		headbob_time += delta * headbob_speed * speed_factor
		camera.position.y = camera_base_y + sin(headbob_time) * headbob_strength * speed_factor
	else:
		camera.position.y = lerp(camera.position.y, camera_base_y, delta * 10.0)

func _update_footsteps(delta: float) -> void:
	var is_moving = velocity.length() > 0.1 and is_on_floor()
	if is_moving:
		var speed_factor = velocity.length() / SPEED
		footstep_interval = 0.25 if Input.is_action_pressed("sprint") else 0.4
		footstep_timer -= delta * speed_factor
		if footstep_timer <= 0.0:
			footstep_timer = footstep_interval
			current_surface = _get_floor_material()
			if FOOTSTEP_SOUNDS.has(current_surface):
				FOOTSTEP_SOUNDS[current_surface].play()
	else:
		footstep_timer = footstep_interval  # reset to full interval so it doesn't fire immediately on next step
		var surface = current_surface
		if FOOTSTEP_SOUNDS.has(surface):
			FOOTSTEP_SOUNDS[surface].stop()  # stop any playing sound immediately

func _get_floor_material() -> String:
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = from + Vector3(0, -1.2, 0)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result and result.collider:
		var collider = result.collider
		if collider.is_in_group("wood"):
			return "wood"
		elif collider.is_in_group("grass"):
			return "grass"
		else:
			return "concrete"
	return "concrete"

func use_item(item_id: String) -> void:
	hand.equip(item_id)

func drop_item() -> void:
	hand.unequip()

var last_interactable: Interactable = null

func _do_raycast() -> void:
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * 3.0)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result:
		var hit = result.collider
		var interactable = hit if hit is Interactable else hit.get_parent()
		if interactable is Interactable and not Global.is_interacting:
			if not interactable.has_interacted:
				if last_interactable and last_interactable != interactable:
					last_interactable.hide_prompt()
				last_interactable = interactable
				interactable.show_prompt()
				if Input.is_action_just_pressed("interact"):
					interactable.interact()
					interactable.hide_prompt()
				return
	if last_interactable:
		last_interactable.hide_prompt()
		last_interactable = null

func _start_regen_with_delay():
	if stamina_tween:
		stamina_tween.kill()
	regen_timer = get_tree().create_timer(1.0)
	var captured_timer = regen_timer
	await captured_timer.timeout
	if captured_timer == regen_timer:
		_regen_stamina()

func _regen_stamina():
	if stamina_tween:
		stamina_tween.kill()
	stamina_tween = create_tween()
	var regen_duration = (100.0 - stamina_value) / 100.0 * 5.0
	stamina_tween.tween_property(stamina, "value", 100.0, regen_duration)
	await stamina_tween.finished
	stamina_value = 100.0
	can_sprint = true
	var fade = create_tween()
	fade.tween_property(stamina, "modulate:a", 0.0, 0.5)
	await fade.finished
	_set_stamina_visible(false)
	stamina.modulate.a = 1.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
