# zoom_controller.gd
# Godot 4 - attach to any Node. Configure `target_control_path` to the ColorRect (Control)
# that you want to scale. Configure `target_material_path` to the Control/Mesh that holds
# the ShaderMaterial with the `pixel_scale` uniform (can be the same control).
class_name ZoomController
extends Node


# how much a wheel step affects zoom velocity (log-space). positive = zoom in
@export var wheel_strength := 0.8

# damping in seconds^-1 (higher = stop faster). try 3..8
@export var damping := 4.5

# minimum / maximum scale (multiplicative)
@export var min_scale := 0.25
@export var max_scale := 8.0

# initial scale (if control already scaled we read it on ready)
@export var initial_scale := 1.0

# duplicate the material to avoid changing shared resource
@export var duplicate_material := true
@export var STOP_RECALCULATING_VELOCITY  := 10.0

# tiny thresholds
const VELOCITY_EPS := 1e-2
const BIGGER_EPS := 1.2 * 1e-2
const MIN_DT := 1.0 / 240.0

# internal state
@export var _control: ColorRect


var _shader_material: ShaderMaterial = null

# using log-space for smooth multiplicative zoom:
var _zoom_log := 0.0       # ln(scale)
var _zoom_vel := 0.0       # d(ln(scale))/dt, i.e. fractional speed (1.0 means scale grows by e^1 per second)

# base pixel_scale read from shader on ready (if available)
var _base_pixel_scale := 360.0

func _ready() -> void:
	# read initial scale
	var start_scale = initial_scale

	# initialize log/vel
	_zoom_log = log(max(min(start_scale, max_scale), min_scale))
	_zoom_vel = 0.0

	# find shader material and optionally duplicate it

	var mat = null
	if "material" in _control:
		mat = _control.material
	elif "material_override" in _control:
		mat = _control.material_override

	if mat and mat is ShaderMaterial:
		_shader_material = mat
		if duplicate_material:
			_shader_material = mat.duplicate() as ShaderMaterial
			if "material" in _control:
				_control.material = _shader_material
			elif "material_override" in _control:
				_control.material_override = _shader_material
		_base_pixel_scale = _shader_material.get_shader_parameter("pixel_scale")

	# apply initial visuals
	apply_scale_and_shader(0.1)

func _input(event):
	# wheel up/down (scroll). Godot exposes constants BUTTON_WHEEL_UP / BUTTON_WHEEL_DOWN
	if event is InputEventMouseButton:
		var idx = int(event.button_index)
		if (idx == MOUSE_BUTTON_WHEEL_UP or idx == 4) and event.pressed:
			# wheel up -> zoom in: add positive velocity
			_zoom_vel += wheel_strength
		elif (idx == MOUSE_BUTTON_WHEEL_DOWN or idx == 5) and event.pressed:
			# wheel down -> zoom out: add negative velocity
			_zoom_vel += -wheel_strength

func _process(delta: float) -> void:
	# integrate zoom velocity in log-space
	var skip_recalculating = false
	if abs(_zoom_vel) > VELOCITY_EPS:
		_zoom_log += _zoom_vel * delta
		# exponential damping
		var damp = exp(-damping * delta)
		_zoom_vel *= damp
		if abs(_zoom_vel) < VELOCITY_EPS:
			_zoom_vel = 0.0
		elif BIGGER_EPS < abs(_zoom_vel) and abs(_zoom_vel) < STOP_RECALCULATING_VELOCITY:
			skip_recalculating = true

	# compute scale and clamp
	var scale = clamp(exp(_zoom_log), min_scale, max_scale)


	# if reaching clamps, stop velocity in that direction and clamp log
	if scale <= min_scale and _zoom_vel < 0.0:
		_zoom_vel = 0.0
		_zoom_log = log(min_scale)
		scale = min_scale
	elif scale >= max_scale and _zoom_vel > 0.0:
		_zoom_vel = 0.0
		_zoom_log = log(max_scale)
		scale = max_scale
	# apply visuals and shader every frame
	apply_scale_and_shader(skip_recalculating)
	# update control scale & shader parameter (only if control/material present)

# helper: apply rect_scale and update shader pixel_scale to keep pixel size constant
@export var position_lerp_speed := 12.0  # higher = faster position animation

func get_scale() -> float:
	return _base_pixel_scale * exp(_zoom_log)
	
func apply_scale_and_shader(skip_pixels:bool) -> void:
	if not _control:
		return

	# compute raw scale & the effective pixel_scale used by the shader
	var scale = exp(_zoom_log)
	var effective_pixel_scale = _base_pixel_scale * scale

	# rounded_scale snaps the visual scale so the UV grid aligns to integer pixel cells
	var rounded_scale = round(scale * effective_pixel_scale) / effective_pixel_scale

	# update shader pixel_scale (bigger visual scale -> bigger pixel_scale as discussed)
	if _shader_material and not skip_pixels:
		_shader_material.set_shader_parameter("pixel_scale", effective_pixel_scale)

	# Compute the current global center of the control BEFORE changing scale.
	# global_position + (rect_size * rect_scale) * 0.5
	var old_pos = _control.get_rect().position
	var center = old_pos + _control.get_rect().size * 0.5

	# Apply the new visual scale immediately (we animate the position separately)
	
	if "scale" in _control:
		_control.scale = Vector2(rounded_scale, rounded_scale)
	# Compute the target top-left (global) so the control's center matches center_global
	var new_size = _control.get_rect().size
	var target_pos = center - new_size * 0.5

	# Smoothly move the control's global position toward the target (exponential smoothing)
	# t = 1 - exp(-k * dt) gives frame-rate independent smoothing
	#var cur_global_pos = _control.get_global_position()
	#var new_global_pos = cur_global_pos.lerp(target_global_pos, t)
	_control.set_position(target_pos)
