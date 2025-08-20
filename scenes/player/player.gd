# Player.gd (Godot 4.x, GDScript)
extends CharacterBody3D

@onready var cam: Camera3D = $Camera3D

# --- Tunables ---
const WALK_SPEED := 4.5
const SPRINT_SPEED := 7.5
const JUMP_VELOCITY := 4.0
const GRAVITY := 9.8
const MOUSE_SENS := 0.12
const PITCH_LIMIT := 89.0

var yaw_deg := 0.0
var pitch_deg := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw_deg -= event.relative.x * MOUSE_SENS
		pitch_deg -= event.relative.y * MOUSE_SENS
		pitch_deg = clamp(pitch_deg, -PITCH_LIMIT, PITCH_LIMIT)

		rotation_degrees.y = yaw_deg
		cam.rotation_degrees.x = pitch_deg

	if event.is_action_pressed("ui_cancel"):
		# FIXED: Python-style ternary
		var mode := Input.get_mouse_mode()
		Input.set_mouse_mode(
			Input.MOUSE_MODE_VISIBLE if mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Direction relative to where you're looking (yaw only)
	var forward := -transform.basis.z
	var right := transform.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	var direction := (right * input_vec.x + forward * input_vec.y).normalized()

	# Horizontal velocity (x,z)
	if direction != Vector3.ZERO:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	# Gravity + jump
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()
