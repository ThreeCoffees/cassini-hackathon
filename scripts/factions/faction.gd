class_name Faction extends Node

const population_starter_multiplier: int = 1
const population_max_multiplier: int = 3
const food_threshhold: int = 1
const population_growth_time: float = 5.0
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

var timer: Timer

# Zwraca listę kafli miasta

func _get_city_tiles() -> Array[Vector2i]:
	return city_tiles

# Dodaje kafel miasta i odświeża informacje frakcji
func add_city_tile(tile_coords: Vector2i)-> void:
	city_tiles.append(tile_coords)
	population = population_starter_multiplier * city_tiles.size()
	max_population = population_max_multiplier * city_tiles.size()
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
	worked_tiles = worked_tiles.filter(func(w): return w.coords != tile.coords)
	update_info()

# Bezpieczny helper: usuwa worked tile po współrzędnych (przydatne z zewnątrz)
func remove_worked_tile_by_coords(coords: Vector2i) -> void:
	worked_tiles = worked_tiles.filter(func(w): return w.coords != coords)
	update_info()

signal update_resources(faction_id: int)

# Przelicza populację, wymagania i zbiory dla frakcji na podstawie miast i pracowanych pól
func update_info():
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
	update_resources.emit(id)
	update_population()

# Zwraca produkcję (yield) dla danego typu zasobu
func get_yields(type: String) -> int:
	match type:
		"wood":
			return wood_yields
		"food":
			return food_yields
		"population":
			return get_population_growth()
		_:
			return 0

func get_population_growth()-> int:
	return 1 if food_yields >= food_requirement + food_threshhold else 0

func update_population():
	if(population < max_population and get_population_growth() == 1): 
		timer.start()

func on_population_update_timeout():
	if(population < max_population and get_population_growth() == 1): 
		population += get_population_growth()
		ResourceManager.resources["population"].storage += get_population_growth()
		update_info()

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

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = population_growth_time
	timer.one_shot = true
	timer.timeout.connect(on_population_update_timeout)
