class_name TileMapGenerator extends TileMapLayer

var tmp_array: Array = []
var tmp_array_height = 128
var tmp_array_width = 128

# CREATE TILEMAP

func prepare_dummy_array():
	tmp_array.resize(tmp_array_width)
	for i in tmp_array_width:
		tmp_array[i] = []
		tmp_array[i].resize(tmp_array_height)
		for j in tmp_array_height:
			tmp_array[i][j] = randi_range(0, 4)
	

func _ready() -> void:
	prepare_dummy_array()
	generate_tilemap()

func generate_tilemap():
	for i in tmp_array_width:
		for j in tmp_array_height:
			set_cell(Vector2i(i, j), 1, Vector2i(tmp_array[i][j], 0), 0)
	
	
	
# MOUSE OPERATIONS 

func global_to_tilemap_coordinates(global_pos):
	var local_pos = to_local(global_pos)
	var hovered_cell = local_to_map(local_pos)
	return hovered_cell
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var selected_cell = global_to_tilemap_coordinates(get_global_mouse_position())
		print("Selected ", selected_cell)
