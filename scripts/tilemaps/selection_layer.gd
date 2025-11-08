class_name SelectionLayer extends TileMapLayer

@export var debug: bool = false

const tile_coords: Dictionary = {
	"city": Vector2i(0, 0),
	"worked": Vector2i(1, 0),
	"occupied": Vector2i(2, 0),
	"none": Vector2i(-1, -1),
}

var occupied_tiles: Array = []


func _on_faction_picked(faction_id: int) -> void:
	if debug:
		print("picked faction %d" % faction_id)

	clear()
	var faction: Faction = CityManager.get_faction(faction_id)
	var city_tiles: Array = faction.city_tiles
	var worked_tiles: Array = faction.worked_tiles

	for cell_coords: Vector2i in city_tiles:
		set_cell(cell_coords, 0, tile_coords["city"])

	for cell_coords: Vector2i in occupied_tiles:
		set_cell(cell_coords, 0, tile_coords["occupied"])

	for cell_coords: Vector2i in worked_tiles:
		set_cell(cell_coords, 0, tile_coords["worked"])



func _on_worked_tile_picked(faction_id: int, cell_coords: Vector2i) -> void:
	var faction = CityManager.get_faction(faction_id)

	var tile_coord = get_cell_atlas_coords(cell_coords)

	if debug:
		print("picked worked tile %d %d" % [tile_coord.x, tile_coord.y])
	if tile_coord == tile_coords["none"]:
		faction.add_worked_tile(cell_coords)
		occupied_tiles.append(cell_coords)
		set_cell(cell_coords, 0, tile_coords["worked"])
	elif tile_coord == tile_coords["worked"]:
		faction.remove_worked_tile(cell_coords)
		occupied_tiles.erase(cell_coords)
		set_cell(cell_coords)
