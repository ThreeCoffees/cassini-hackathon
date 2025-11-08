extends Node


# w tym projekcie tilemapy używają atlasowych współrzędnych,
# gdzie indeks "2" odpowiada typowi WOODS/forest (zgodnie z TerrainTilemapLayer.TileTypes).

@export var forest_hp: int = 50

var hp_map: Dictionary[Vector2i, int]= {}  
var tilemap_ref: TerrainTilemapLayer = null
var selection_layer: SelectionLayer

# Przypisuje domyślne HP dla wszystkich pól lasu na podanej TileMap
func assign_hp_to_tilemap(tilemap: TerrainTilemapLayer, sel: SelectionLayer) -> Dictionary:
	hp_map.clear()
	tilemap_ref = tilemap
	selection_layer = sel

	for coords in tilemap.get_used_cells_by_id(1, Vector2i(2, 0)):
		print(coords)
		hp_map.set(coords, forest_hp)
	return hp_map

# Zwraca HP pola (lub -1 jeśli brak)
func get_hp(cell: Vector2i) -> int:
	if !hp_map.has(cell):
		return -1
	return hp_map.get(cell)

# Zmniejsza HP pola o podaną wartość, zwraca true jeśli zastosowano
func damage(cell, amount := 1) -> bool:
	if not hp_map.has(cell):
		return false

	hp_map[cell] = max(0, hp_map[cell] - int(amount))
	# Jeśli HP spadło do 0, podmień kafelek na czarny (atlas index 0,0) i usuń z mapy HP
	if hp_map[cell] <= 0:
		tilemap_ref.set_cell(cell, 1, Vector2i(0, 0), 0)

		# Usuń wpis HP
		hp_map.erase(cell)

		# Spróbuj usunąć pracowane pole z każdej frakcji, jeśli było przypisane.
		var faction = CityManager.get_cell_faction(cell)
		if faction != null:
			faction.remove_worked_tile_by_coords(cell)
			print(selection_layer)
			selection_layer.clear_worked_tile(cell, faction.id)
	return true

# Zwiększa HP pola o podaną wartość, zwraca true jeśli zastosowano
func restore_hp(cell, amount := 1) -> bool:
	if not hp_map.has(cell):
		return false
	hp_map[cell] += int(amount)
	return true
