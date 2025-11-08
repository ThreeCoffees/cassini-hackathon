extends Node

var faction_count = 0
var _city_tile_faction: Dictionary[Vector2i, int] = {}
var _faction_city_tiles: Array[Array] = []

# returns faction id of the specified city cell. Returns -1 if provided coords aren't a city tile.
func get_cell_faction_id(cell_coords: Vector2i) -> int:
	return _city_tile_faction.get(cell_coords, -1);

# returns all city cells of a faction specified by the id.
func get_faction_id_cells(faction_id: int) -> Array:
	if faction_id >= faction_count:
		return []
	return _faction_city_tiles[faction_id]

func create_cities(tilemap: TileMapLayer):
	var all_city_cells = tilemap.get_used_cells_by_id(1, Vector2i(4,0));

	for cell in all_city_cells:
		_city_tile_faction.set(cell, -1)

	for cell_coords in _city_tile_faction.keys():
		if _city_tile_faction.get(cell_coords) == -1:
			_faction_city_tiles.append([])
			_flood_fill(cell_coords)
			faction_count+=1


func _flood_fill(cell_coords: Vector2i):
	var cell_factions = _city_tile_faction.get(cell_coords);
	if cell_factions == null or cell_factions != -1:
		return

	_city_tile_faction.set(cell_coords, faction_count)
	_faction_city_tiles[faction_count].append(cell_coords)

	var x = cell_coords.x
	var y = cell_coords.y

	_flood_fill(Vector2i(x+1, y))
	_flood_fill(Vector2i(x-1, y))
	_flood_fill(Vector2i(x, y+1))
	_flood_fill(Vector2i(x, y-1))
