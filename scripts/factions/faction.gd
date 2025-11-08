class_name Faction extends Node

const population_starter_multiplier: int = 1
const population_max_multiplier: int = 3
const food_req_mul: float = 0.1
const energy_req_mul: float = 0.1

const food_prod_mul: int = 16
const wood_prod_mul: int = 4

static var faction_count: int = 0

class WorkedTile:
	var coords: Vector2i
	var type: TerrainTilemapLayer.TileTypes

var id: int
var city_tiles: Array[Vector2i] = []: get = _get_city_tiles
var worked_tiles: Array[WorkedTile] = []

var population: int
var max_population: int
var food_requirement: float
var energy_requirement: float

var food_yields: int
var wood_yields: int

# Zwraca listę kafli miasta
func _get_city_tiles() -> Array[Vector2i]:
	return city_tiles

# Dodaje kafel miasta i odświeża informacje frakcji
func add_city_tile(tile_coords: Vector2i)-> void:
	city_tiles.append(tile_coords)
	update_info()

# Zwraca listę obsługiwanych (worked) kafli
func _get_worked_tiles() -> Array[WorkedTile]:
	return worked_tiles

# Zwraca tablicę współrzędnych obsługiwanych kafli
func get_worked_tiles_coords() -> Array:
	return worked_tiles.map(func(tile: WorkedTile): return tile.coords)

# Dodaje nowe obsługiwane pole i odświeża informacje
func add_worked_tile(new_tile: WorkedTile)-> void:
	worked_tiles.append(new_tile)
	update_info()

# Usuwa obsługiwane pole i odświeża informacje
func remove_worked_tile(tile: WorkedTile) -> void:
	var idx = worked_tiles.find(tile)
	if idx == -1:
		return
	worked_tiles.remove_at(idx)
	update_info()

	# Bezpieczny helper: usuwa worked tile po współrzędnych (przydatne z zewnątrz)
func remove_worked_tile_by_coords(coords: Vector2i) -> void:
	for i in range(worked_tiles.size()):
		if worked_tiles[i].coords == coords:
			worked_tiles.remove_at(i)
			update_info()
			return
	# (no additional helpers here; keep API minimal)

signal update_resources

# Przelicza populację, wymagania i zbiory dla frakcji na podstawie miast i pracowanych pól
func update_info():
	population = population_starter_multiplier * city_tiles.size()
	max_population = population_max_multiplier * city_tiles.size()
	food_requirement = population * food_req_mul
	energy_requirement = population * energy_req_mul

	food_yields = 0
	wood_yields = 0
	for tile in worked_tiles:
		match tile.type:
			TerrainTilemapLayer.TileTypes.WOODS:
				wood_yields += wood_prod_mul
			TerrainTilemapLayer.TileTypes.AGRI:
				food_yields += food_prod_mul
	
	update_resources.emit()

# Zwraca produkcję (yield) dla danego typu zasobu
func get_yields(type: String) -> int:
	match type:
		"wood":
			return wood_yields
		"food":
			return food_yields
		"energy":
			return 0
		_:
			return 0

# Zwraca koszty/wymagania dla danego typu zasobu
func get_costs(type: String) -> float:
	match type:
		"wood":
			return 0
		"food":
			return food_requirement
		"energy":
			return energy_requirement
		_:
			return 0
	

# Sprawdza, czy frakcja może dodać kolejne pracowane pole (limit: populacja)
func can_add_work()-> bool:
	if worked_tiles.size() >= population:
		return false
	return true

# Wypisuje debugowo stan frakcji
func print():
	print("Faction %d: no_city_tiles: %d, no_worked_tiles: %d, population: %d, food: %d, energy: %d" % [id , city_tiles.size() , worked_tiles.size() , population , food_requirement , energy_requirement])

# Inicjalizuje frakcję (przypisuje id i podłącza sygnały)
func _init():
	id = faction_count
	faction_count+=1

	update_resources.connect(ResourceManager.on_update_resources)
