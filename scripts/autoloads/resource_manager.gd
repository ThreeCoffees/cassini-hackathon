extends Node

signal global_resources_updated()

class ResourceData:
	var total_yield: int
	var total_cost: int
	var storage: int
	var type: String

	func get_label() -> String:
		return "%d | %d/day" % [storage, get_change()]

	func get_change() -> int:
		return total_yield - total_cost

	func update_change():
		calculate_total_yield()
		calculate_total_cost()

	func update_storage():
		storage += get_change()
	
	func calculate_total_yield():
		match type:
			"energy":
				total_yield = ResourceManager.plants.reduce(func(sum: int, plant: PowerPlant): return sum + plant.energy_production_multiplier, 0) 
			_:
				total_yield = CityManager.get_all_factions().reduce(func(sum: int, faction): return sum + faction.get_yields(type), 0)

	func calculate_total_cost():
		total_cost = CityManager.get_all_factions().reduce(func(sum: int, faction): return sum + faction.get_costs(type), 0)
	
	func _init(new_type: String):
		type = new_type
	

var resources: Dictionary[String, ResourceData] = {}
var forest_hp_node = null

var plants: Array[PowerPlant] = []

func initialize_resources():
	resources.set("wood", ResourceData.new("wood"))
	resources.set("food", ResourceData.new("food"))
	resources.set("energy", ResourceData.new("energy"))
	resources.set("population", ResourceData.new("population"))

	on_update_resources()


func calculate_stores():
	for resource in resources.values():
		resource.update_storage()
	global_resources_updated.emit()

	# For each worked WOODS tile, reduce its HP by 1 (same tempo as resource tick)
	if forest_hp_node != null:
		for faction in CityManager.get_all_factions():
			for wt in faction.worked_tiles:
				if wt.type == TerrainTilemapLayer.TileTypes.WOODS:
					forest_hp_node.damage(wt.coords, 2)

	# Note: forest_hp_node should be registered by the terrain generator after creation


func register_forest_hp(node):
	# Store reference to the ForestHP node so ResourceManager can decrement HP over time
	forest_hp_node = node


func on_update_resources():
	for resource in resources.values():
		resource.update_change()
	global_resources_updated.emit()
	
	
func use_resources(type : String, number : int):
	print("At first:")
	print(resources[type].storage)			# gets number of type resource from the storage
	var current = resources[type].storage
	current = current - number
	resources[type].storage = current
	print("After:")
	print(resources[type].storage)	
	global_resources_updated.emit()

func how_much_resource(type : String):
	return resources[type].storage
	
	
	
