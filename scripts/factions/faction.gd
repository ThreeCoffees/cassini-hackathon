class_name Faction extends Node

signal happiness_changed(value)

const population_starter_multiplier: int = 2
const food_multiplier: int = 2
const energy_multiplier: int = 2

static var faction_count: int = 0

var id: int
var city_tiles: Array[Vector2i] = []: get = _get_city_tiles
var worked_tiles: Array[Vector2i] = []

var population: int
var food_requirement: int
var energy_requirement: int

func _get_city_tiles() -> Array[Vector2i]:
	return city_tiles

func add_city_tile(tile_coords: Vector2i)-> void:
	city_tiles.append(tile_coords)
	update_info()

func update_info():
	population = population_starter_multiplier * city_tiles.size()
	food_requirement = population * food_multiplier
	energy_requirement = population * energy_multiplier
	happiness_changed.emit(food_requirement * -1)

func print():
	print("Faction %d: no_city_tiles: %d, no_worked_tiles: %d, population: %d, food: %d, energy: %d" % [id , city_tiles.size() , worked_tiles.size() , population , food_requirement , energy_requirement])

func _init():
	id = faction_count
	faction_count+=1
