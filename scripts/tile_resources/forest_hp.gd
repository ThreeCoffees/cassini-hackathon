extends Node


# w tym projekcie tilemapy używają atlasowych współrzędnych,
# gdzie indeks "2" odpowiada typowi WOODS/forest (zgodnie z TerrainTilemapLayer.TileTypes).

@export var forest_hp := 50
@export var forest_atlas_index := 2

var hp_map := {} # klucz: "(x,y)" -> int HP
var tilemap_ref = null

# Przypisuje domyślne HP dla wszystkich pól lasu na podanej TileMap
func assign_hp_to_tilemap(tilemap) -> Dictionary:
	# Zakładamy, że tilemap ma metodę get_used_rect() i get_cell_atlas_coords(cell: Vector2i)
	hp_map.clear()
	tilemap_ref = tilemap
	var rect = tilemap.get_used_rect()
	for x in range(int(rect.position.x), int(rect.position.x + rect.size.x)):
		for y in range(int(rect.position.y), int(rect.position.y + rect.size.y)):
			var cell = Vector2i(x, y)
			var atlas = tilemap.get_cell_atlas_coords(cell)
			# atlas.x przechowuje indeks kafla (0..n)
			if atlas.x == int(forest_atlas_index):
				hp_map["(" + str(x) + "," + str(y) + ")"] = int(forest_hp)
	return hp_map

# Zwraca HP pola (lub null jeśli brak)
func get_hp(cell) -> int:
	var key = "(" + str(int(cell.x)) + "," + str(int(cell.y)) + ")"
	return hp_map.get(key)

# Zmniejsza HP pola o podaną wartość, zwraca true jeśli zastosowano
func damage(cell, amount := 1) -> bool:
	var key = "(" + str(int(cell.x)) + "," + str(int(cell.y)) + ")"
	if not hp_map.has(key):
		return false
	hp_map[key] = max(0, hp_map[key] - int(amount))
	# Jeśli HP spadło do 0, podmień kafelek na czarny (atlas index 0,0) i usuń z mapy HP
	if hp_map[key] <= 0:
		if tilemap_ref != null and tilemap_ref.has_method("set_cell"):
			# Używamy tej samej sygnatury co przy generowaniu: (cell, layer, atlas_coords, something)
			tilemap_ref.set_cell(cell, 1, Vector2i(0, 0), 0)

		# Usuń wpis HP
		hp_map.erase(key)

		# Spróbuj usunąć pracowane pole z każdej frakcji, jeśli było przypisane.
		if typeof(CityManager) != TYPE_NIL:
			for faction in CityManager.get_all_factions():
				if faction.has_method("remove_worked_tile_by_coords"):
					faction.remove_worked_tile_by_coords(cell)

		# Spróbuj wyczyścić wizualnie warstwę zaznaczeń SelectionLayer
		var sel = get_tree().get_root().find_node("SelectionLayer", true, false)
		if sel != null:
			if sel.has_method("clear_worked_tile"):
				sel.clear_worked_tile(cell)
			else:
				if sel.has_method("set_cell"):
					sel.set_cell(cell)
	return true

# Zwiększa HP pola o podaną wartość, zwraca true jeśli zastosowano
func restore_hp(cell, amount := 1) -> bool:
	var key = "(" + str(int(cell.x)) + "," + str(int(cell.y)) + ")"
	if not hp_map.has(key):
		return false
	hp_map[key] += int(amount)
	return true
