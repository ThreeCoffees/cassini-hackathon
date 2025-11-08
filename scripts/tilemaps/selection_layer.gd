class_name SelectionLayer extends TileMapLayer

@export var debug: bool = false
var line_scene: = preload("uid://ctkf2ywe2ftv6")
var linesArr : Array[Line2D]

signal faction_yields_changed(faction_id: int)

const tile_coords: Dictionary = {
	"city": Vector2i(0, 0),
	"worked": Vector2i(1, 0),
	"occupied": Vector2i(2, 0),
	"none": Vector2i(-1, -1),
}

var occupied_tiles: Array = []

func _set_line(coords, faction_id):
	var line:Line2D = line_scene.instantiate()
	var faction: Faction = CityManager.get_faction(faction_id)
	line.add_point(to_global(map_to_local(coords)))
	line.add_point( to_global(map_to_local(faction.city_tiles[0])))
	add_child(line)
	linesArr.append(line)
	
func _remove_lines():
	for line in linesArr:
		line.queue_free()
	linesArr.clear()
	print(linesArr)
		

# Aktualizuje warstwę zaznaczeń po wybraniu frakcji
func _on_faction_picked(faction_id: int) -> void:
	if debug:
		print("picked faction %d" % faction_id)
	print(linesArr)
	_remove_lines()
	clear()
	print(linesArr)
	
	for cell_coords: Vector2i in occupied_tiles:
		set_cell(cell_coords, 0, tile_coords["occupied"])
		
	var faction: Faction = CityManager.get_faction(faction_id)
	if faction != null:
		var city_tiles: Array = faction.city_tiles
		var worked_tiles: Array = faction.get_worked_tiles_coords()

		for cell_coords: Vector2i in city_tiles:
			set_cell(cell_coords, 0, tile_coords["city"])

		for cell_coords: Vector2i in worked_tiles:
			set_cell(cell_coords, 0, tile_coords["worked"])
			_set_line(cell_coords, faction_id)



# Obsługuje kliknięcie na pole pracy (dodaje lub usuwa pracowane pole)
func _on_worked_tile_picked(faction_id: int, cell_coords: Vector2i, cell_type: TerrainTilemapLayer.TileTypes) -> void:
	var faction = CityManager.get_faction(faction_id)

	var tile_coord = get_cell_atlas_coords(cell_coords)

	if debug:
		print("picked worked tile %d %d" % [tile_coord.x, tile_coord.y])
	if tile_coord == tile_coords["none"]:
		if !faction.can_add_work():
			return
		var new_tile: Faction.WorkedTile = Faction.WorkedTile.new()
		new_tile.coords = cell_coords
		new_tile.type = cell_type

		faction.add_worked_tile(new_tile)
		occupied_tiles.append(cell_coords)
		set_cell(cell_coords, 0, tile_coords["worked"])
		_set_line(cell_coords, faction_id)
		
		
	elif tile_coord == tile_coords["worked"]:
		var new_tile: Faction.WorkedTile = Faction.WorkedTile.new()
		new_tile.coords = cell_coords
		new_tile.type = cell_type
		faction.remove_worked_tile(new_tile)
		occupied_tiles.erase(cell_coords)
		set_cell(cell_coords)
	
	faction_yields_changed.emit(faction_id)
