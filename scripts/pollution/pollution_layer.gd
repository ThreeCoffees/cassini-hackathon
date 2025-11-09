class_name PollutionLayer extends TileMapLayer

signal tile_changed(coords: Vector2i)
signal terrain_generated()

func set_cell_emit(coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	set_cell(coords, source_id, atlas_coords, alternative_tile)
	tile_changed.emit(coords)

func on_generation_finished():
	terrain_generated.emit()
