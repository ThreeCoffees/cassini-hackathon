class_name Faction extends Node

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

func _init():
	id = faction_count
	faction_count+=1
