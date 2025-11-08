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
		_handle_drag(event.position)

func _handle_drag(pos: Vector2) -> void:
	var delta = pos - _last_pos
	if delta == Vector2.ZERO:
		_last_pos = pos
		return

	# Horizontal drag changes yaw (rotation around Z)
	# Positive delta.x rotates to the right (adjust sign to taste)
	yaw += -delta.x * sensitivity

	# Vertical drag changes pitch (rotation around X), clamp it
	# Negative sign so dragging up tilts the top of the globe away; change if you prefer the opposite.
	pitch += -delta.y * sensitivity
	pitch = clamp(pitch, min_pitch, max_pitch)

	# Keep yaw numerically sane: reduce magnitude by multiples of 2PI occasionally
	# (this preserves unlimited logical rotation while avoiding runaway floats)
	if abs(yaw) > 1e6:
		# subtract multiples of 2pi
		yaw = fmod(yaw, TAU)

	# Push to shader
	_push_to_shader()

	_last_pos = pos

func _push_to_shader() -> void:
	if _shader_material == null:
		return
	# shader uniforms: surface_rotation_x = pitch; surface_rotation_z = yaw
	_shader_material.set_shader_parameter("surface_rotation_x", pitch if not invert_pitch else -pitch)
	_shader_material.set_shader_parameter("surface_rotation_y", 0) # keep Y unused
	_shader_material.set_shader_parameter("surface_rotation_z", yaw)
