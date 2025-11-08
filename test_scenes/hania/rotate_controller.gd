# drag_yaw_pitch.gd
# Godot 4
extends Node

@export var node: ColorRect

# Sensitivity: radians per pixel
@export var sensitivity := 0.006

# Pitch limits (radians). Example: +/- 80 degrees.
@export var min_pitch := deg_to_rad(-80.0)
@export var max_pitch := deg_to_rad(80.0)

@export var invert_pitch = false
# Duplicate the material to avoid changing shared resource
@export var duplicate_material := true

# Internal state
var _dragging := false
var _last_pos := Vector2.ZERO

# velocities in radians per second
var yaw_vel := 0.0
var pitch_vel := 0.0

# damping: higher == stops quicker. Typical range 2..8 (per second).
@export var angular_damping := 4.0

# velocity below which we snap to zero (rad/s)
const VELOCITY_EPS := 0.0005

# small guard for timestamp dt
const MIN_DT := 1.0 / 240.0

# used to compute velocity during dragging
var _last_drag_time_ms := 0


# rotation state
var yaw := 0.0        # rotation around Z (unlimited)
var pitch := 0.0     # rotation around X (clamped)

var _shader_material: ShaderMaterial = null

func _ready():
	var mat = null
	if "material" in node:
		mat = node.material
	elif "material_override" in node:
		mat = node.material_override

	if mat and mat is ShaderMaterial:
		_shader_material = mat
		if duplicate_material:
			_shader_material = mat.duplicate() as ShaderMaterial
			if "material" in node:
				node.material = _shader_material
			elif "material_override" in node:
				node.material_override = _shader_material

	# initialize shader uniforms
	_push_to_shader()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_last_pos = event.position
			else:
				_dragging = false
	
	elif event is InputEventMouseMotion and _dragging:
		_handle_drag(event.relative, event.position)

func _start_drag(button_event: InputEventMouseButton) -> void:
	_dragging = true
	_last_pos = button_event.position
	_last_drag_time_ms = Time.get_ticks_msec()
	# zero velocities while starting a new drag (optional; preserves inertia if you want continuity)
	yaw_vel = 0.0
	pitch_vel = 0.0
	
func _handle_drag(delta: Vector2, pos: Vector2) -> void:
	if delta == Vector2.ZERO:
		_last_pos = pos
		return

	# convert pixel delta to angle change (radians)
	var ang_dx = -delta.x * sensitivity   # horizontal -> yaw
	var ang_dy = -delta.y * sensitivity   # vertical -> pitch

	# apply instantly so the globe follows the mouse
	yaw += ang_dx
	pitch += ang_dy
	pitch = clamp(pitch, min_pitch, max_pitch)

	# compute instantaneous angular velocity (rad/sec) using timestamp
	var now_ms = Time.get_ticks_msec()
	var dt = max((now_ms - _last_drag_time_ms) / 1000.0, MIN_DT)
	yaw_vel = ang_dx / dt
	pitch_vel = ang_dy / dt
	_last_drag_time_ms = now_ms

	_push_to_shader()
	_last_pos = pos

	
func _process(delta: float) -> void:
	# when dragging, we still update shader from _handle_drag, but we can optionally
	# also apply a small smoothing here (not required). primary inertia behavior occurs when not dragging.
	if not _dragging:
		# integrate velocities to update angles
		if abs(yaw_vel) > VELOCITY_EPS or abs(pitch_vel) > VELOCITY_EPS:
			yaw += yaw_vel * delta
			pitch += pitch_vel * delta
			pitch = clamp(pitch, min_pitch, max_pitch)

			# exponential damping for natural feel: v(t+dt) = v(t) * exp(-damping * dt)
			var damp = exp(-angular_damping * delta)
			yaw_vel *= damp
			pitch_vel *= damp

			# snap to zero if very small
			if abs(yaw_vel) < VELOCITY_EPS:
				yaw_vel = 0.0
			if abs(pitch_vel) < VELOCITY_EPS:
				pitch_vel = 0.0

			_push_to_shader()


func _push_to_shader() -> void:
	if _shader_material == null:
		return
	# shader uniforms: surface_rotation_x = pitch; surface_rotation_z = yaw
	_shader_material.set_shader_parameter("surface_rotation_x", pitch if not invert_pitch else -pitch)
	_shader_material.set_shader_parameter("surface_rotation_y", 0) # keep Y unused
	_shader_material.set_shader_parameter("surface_rotation_z", yaw)
