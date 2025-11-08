class_name TilePicker extends Node

@export var debug: bool = false
@export var terrain_generator: TerrainGenerator

var selected_city: int = -1
enum TileTypes{
	NONE,
	WATER,
	WOODS,
	AGRI,
	CITY,
}
	
func handle_select_cell(cell_coords: Vector2i):
	var x = cell_coords.x
	var y = cell_coords.y
	var selected_type = terrain_generator.terrain_array[x][y]
	if debug:
		print("Selected ", cell_coords)

	match selected_type:
		TileTypes.CITY:
			selected_city = CityManager.get_cell_faction_id(cell_coords)
			if debug:
				print("CITY STANDS AT YOUR COMMAND: ", selected_city)
		TileTypes.AGRI, TileTypes.WOODS:
			if selected_city != -1:
				if debug:
					print("GET BACK TO WORK")
				pass
		_:
			pass
