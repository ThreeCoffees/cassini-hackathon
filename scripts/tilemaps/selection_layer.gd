class_name SelectionLayer extends TileMapLayer

@export var debug: bool = false

func _on_faction_picked(faction_id: int) -> void:
	if debug:
		print("picked faction %d" % faction_id)

	clear()
	var faction_cells: Array = CityManager.get_faction_id_cells(faction_id)

	for cell_coords: Vector2i in faction_cells:
		set_cell(cell_coords, 0, Vector2i(0,0))
