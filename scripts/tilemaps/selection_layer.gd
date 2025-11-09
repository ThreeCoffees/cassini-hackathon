class_name SelectionLayer extends TileMapLayer

@export var debug: bool = false
var line_scene: = preload("uid://ctkf2ywe2ftv6")
var linesArr : Array

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

func _remove_line(coords):
	var cmp = func(line: Line2D) -> bool:
		return line.points[0] == to_global(map_to_local(coords))
	var line_idx = linesArr.find_custom(cmp)
	if line_idx == -1:
		return
	var line_to_delete = linesArr[line_idx]
	var keep = func(line: Line2D) -> bool:
		return line.points[0] != to_global(map_to_local(coords))
	linesArr = linesArr.filter(keep)

	line_to_delete.queue_free()

# Public helper do bezpiecznego odznaczania pracowanego pola
func clear_worked_tile(cell_coords: Vector2i, faction_id: int) -> void:
	occupied_tiles.erase(cell_coords)
	set_cell(cell_coords)
	_remove_line(cell_coords)
	faction_yields_changed.emit(faction_id)


# Aktualizuje warstwę zaznaczeń po wybraniu frakcji
func _on_faction_picked(faction_id: int) -> void:
	if debug:
		print("picked faction %d" % faction_id)
	_remove_lines()
	clear()
	
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
		_remove_line(cell_coords)
	
	faction_yields_changed.emit(faction_id)


# Public helper: pick multiple tiles at once for a faction to work.
# - `cells` should be an Array of Vector2i
# - respects `faction.can_add_work()` (stops when faction can't add more)
func pick_multiple_worked_tiles(faction_id: int, cells: Array, cell_type: TerrainTilemapLayer.TileTypes) -> void:
	var faction: Faction = CityManager.get_faction(faction_id)
	if faction == null:
		return

	for cell_coords in cells:
		# Stop if faction reached its work limit
		if not faction.can_add_work():
			break

		var tile_coord = get_cell_atlas_coords(cell_coords)
		if tile_coord == tile_coords["none"]:
			var new_tile: Faction.WorkedTile = Faction.WorkedTile.new()
			new_tile.coords = cell_coords
			new_tile.type = cell_type

			faction.add_worked_tile(new_tile)
			occupied_tiles.append(cell_coords)
			set_cell(cell_coords, 0, tile_coords["worked"])
			_set_line(cell_coords, faction_id)

	faction_yields_changed.emit(faction_id)
