class_name CityManager extends Node

@export var tilemap: TileMapLayer

var faction_count = 0
var _city_tile_faction: Dictionary[Vector2i, int] = {}
var _faction_city_tiles: Array[Array] = []

# returns faction id of the specified city cell. Returns -1 if provided coords aren't a city tile.
func get_faction_of_cell(cell_coords: Vector2i) -> int:
	return _city_tile_faction.get(cell_coords, -1);

# returns all city cells of a faction specified by the id.
func get_all_cells_of_faction(faction_id: int) -> Array[Vector2i]:
	if faction_id >= faction_count:
		return []
	return _faction_city_tiles[faction_id]

func create_cities():
	var all_city_cells = tilemap.get_used_cells_by_id(1, Vector2i(4,0));

	for cell in all_city_cells:
		_city_tile_faction.set(cell, -1)

	for cell_coords in _city_tile_faction.keys():
		if _city_tile_faction.get(cell_coords) == -1:
			_faction_city_tiles.append([])
			flood_fill(cell_coords)
			faction_count+=1


func flood_fill(cell_coords: Vector2i):
	var cell_factions = _city_tile_faction.get(cell_coords);
	if cell_factions == null or cell_factions != -1:
		return

	_city_tile_faction.set(cell_coords, faction_count)
	_faction_city_tiles[faction_count].append(cell_coords)

	var x = cell_coords.x
	var y = cell_coords.y

	flood_fill(Vector2i(x+1, y))
	flood_fill(Vector2i(x-1, y))
	flood_fill(Vector2i(x, y+1))
	flood_fill(Vector2i(x, y-1))

func _ready():
	create_cities()
