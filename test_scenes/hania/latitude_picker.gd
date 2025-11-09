extends Node
# utils.gd (Godot 4 GDScript)
# Returns (lat_deg, lon_deg) by default. Set 'degrees=false' to return radians.

@export var earth_node: ColorRect
var shader_material
var latlon:Vector2
func _ready() -> void:
	shader_material = earth_node.material as ShaderMaterial

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("select_location_on_earth"):
		var p = shader_material.get_shader_parameter("surface_rotation_x")
		var y = shader_material.get_shader_parameter("surface_rotation_z")
		var latlonlocal = pitch_yaw_to_latlon(-p, y)
		latlon = latlonlocal
		print("lat %s lon %s" % [latlon.x, latlon.y])

# maps pitch/yaw -> (lat_deg, lon_deg)
func pitch_yaw_to_latlon(pitch: float, yaw: float) -> Vector2:
	const PI = 3.141592653589793
	# clamp pitch to valid range to avoid nonsense latitudes
	var p = clamp(pitch, -PI*0.5, PI*0.5)

	# latitude mapping: lat = -pitch (radians) -> degrees
	var lat_deg = -p * 180.0 / PI

	# longitude: convert yaw to degrees and wrap into (-180, 180]
	var lon_deg = yaw * 180.0 / PI

	# robust wrap: make value in [0,360) then shift to (-180,180]
	lon_deg = fmod(lon_deg + 180.0, 360.0)
	if lon_deg < 0.0:
		lon_deg += 360.0
	lon_deg -= 180.0

	return Vector2(lat_deg, lon_deg)
	


func _on_button_pressed():
	print('start')
	var p = shader_material.get_shader_parameter("surface_rotation_x")
	var y = shader_material.get_shader_parameter("surface_rotation_z")
	var latlonlocal = pitch_yaw_to_latlon(-p, y)
	latlon = latlonlocal
	print("lat %s lon %s" % [latlon.x, latlon.y])
	MapDataGlobal.fetch_map(latlon)
	print('end')
