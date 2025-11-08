class_name TerrainTilemapLayer extends TileMapLayer

@export var tile_picker: TilePicker

func global_to_tilemap_coordinates(global_pos):
	var local_pos = to_local(global_pos)
	var hovered_cell = local_to_map(local_pos)
	return hovered_cell
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var selected_cell = global_to_tilemap_coordinates(get_global_mouse_position())
		tile_picker.handle_select_cell(selected_cell)
		
