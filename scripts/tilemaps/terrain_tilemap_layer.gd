class_name TerrainTilemapLayer extends TileMapLayer

@export var debug: bool = false

signal faction_picked(faction_id: int)
signal plant_position_picked(position :Vector2i)

var selected_city: int = -1: set = _on_selected_city_set

func _on_selected_city_set(new_city: int):
	selected_city = new_city
	faction_picked.emit(selected_city)

enum TileTypes{
	NONE,
	WATER,
	WOODS,
	AGRI,
	CITY,
}

func global_to_tilemap_coordinates(global_pos):
	var local_pos = to_local(global_pos)
	var hovered_cell = local_to_map(local_pos)
	return hovered_cell
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		selected_city = -1
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var selected_cell = global_to_tilemap_coordinates(get_global_mouse_position())
		if debug: 
			print("clicked tilemap layer (%d, %d)" % [selected_cell.x, selected_cell.y])

		handle_select_cell(selected_cell)

func get_cell_type(coords: Vector2i) -> TileTypes:
	if !get_used_rect().has_point(coords):
		return TileTypes.NONE
	return get_cell_atlas_coords(coords).x as TileTypes
		
func handle_select_cell(cell_coords: Vector2i):
	match get_cell_type(cell_coords):
		TileTypes.CITY:
			selected_city = CityManager.get_cell_faction_id(cell_coords)
			if debug:
				print("CITY STANDS AT YOUR COMMAND: ", selected_city)
		TileTypes.AGRI, TileTypes.WOODS:
			if selected_city != -1:
				if debug:
					print("GET BACK TO WORK")
		TileTypes.NONE:
			plant_position_picked.emit(map_to_local(cell_coords))
