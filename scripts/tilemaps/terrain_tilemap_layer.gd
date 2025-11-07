class_name TileMapGenerator extends TileMapLayer

var tmp_array: Array = []
var tmp_array_height = 128
var tmp_array_width = 128

var selected_city = null
enum TileTypes{
	CITY,
	AGRI,
	WOODS,
	WATER
}
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
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var selected_cell = global_to_tilemap_coordinates(get_global_mouse_position())
		var x = selected_cell.x
		var y = selected_cell.y
		var selected_type = tmp_array[x][y]
		print("Selected ", selected_cell)
		
		if selected_type == TileTypes.CITY:
			print("CITY STANDS AT YOUR COMMAND")
			selected_city = selected_cell
		
		if (selected_city != null) and (selected_type == TileTypes.AGRI or selected_type == TileTypes.WOODS):
			print("GET BACK TO WORK")
		
