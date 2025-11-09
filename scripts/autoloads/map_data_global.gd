extends Node
class_name MapData
var data
var width = 128
var height = 128
var terrain_array: Array[Array] = []

func fetch_map(latlon: Vector2):
	var http = $/root/InteractivePlanet/HTTPRequest
	http.request_completed.connect(_on_request_completed)
	var result = null
	result = http.request(
		"https://tileworld.electimore.xyz/api/v2/terrain/?lat="
		+str(latlon.x)+"&lon="+str(latlon.y))
	await http.request_completed
	print(result)
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	prepare_CHAD_array(json["terrain_data"])
	
	get_tree().change_scene_to_file("res://test_scenes/main_scene.tscn")
	

func prepare_CHAD_array(arr):
	terrain_array.resize(width)
	for i in width:
		terrain_array[i] = []
		terrain_array[i].resize(height)	
		for j in height:
			terrain_array[i][j] = arr[i][j]
	data = terrain_array
			
