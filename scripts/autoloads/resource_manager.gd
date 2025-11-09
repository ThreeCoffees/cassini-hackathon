extends Node

signal global_resources_updated()

class ResourceData:
	var total_yield: int
	var total_cost: int
	var storage: int
	var type: String
	var debuff : int

	func get_label() -> String:
		if type == "population":
			return "%d" % storage
		return "%d | %d/day" % [storage, get_change()]

	func get_change() -> int:
		if type == "population":
			return 0
		return total_yield - total_cost - debuff # tutaj dodaje bo mi sie to wydaje najlogiczniejsze

	func update_change():
		calculate_total_yield()
		calculate_total_cost()

	func update_storage():
		storage += get_change()
	
	func calculate_total_yield():
		match type:
			"energy":
				var sum_fn = func(sum: int, plant: PowerPlant) -> int:
					return sum + plant.energy_production_multiplier
				total_yield = ResourceManager.plants.reduce(sum_fn, 0)
			_:
				var sum_fn2 = func(sum: int, faction) -> int:
					return sum + faction.get_yields(type)
				total_yield = CityManager.get_all_factions().reduce(sum_fn2, 0)

	func get_total_energy_consumption(faction: Faction) -> int:
		var sum = 0
		#for faction in CityManager._faction_infos:
		sum += faction.worked_tiles.size()
		return sum
			
	func calculate_total_cost():
		var cost_fn = func(sum: int, faction) -> int:
			var energy_cost = get_total_energy_consumption(faction) if type == "energy" else 0
		
			return sum + faction.get_costs(type) + energy_cost
		total_cost = CityManager.get_all_factions().reduce(cost_fn, 0)
	
	func _init(new_type: String):
		type = new_type
		debuff = 0

# total prototype
func add_debuffs(arr : Array[int]):
	debuffs = arr
	resources["wood"].debuff = arr[0]
	resources["food"].debuff = arr[1]
	resources["energy"].debuff = arr[2]

var debuffs : Array[int] = [] # ilosc kolejno zanieczyszczen na wood, agri i city

var resources: Dictionary[String, ResourceData] = {}
var forest_hp_node = null

var plants: Array[PowerPlant] = []
 
var population_happiness: int = -1
func initialize_resources():
	resources.set("wood", ResourceData.new("wood"))
	resources.set("food", ResourceData.new("food"))
	resources.set("energy", ResourceData.new("energy"))
	resources.set("population", ResourceData.new("population"))

	for faction in CityManager.get_all_factions():
		resources["population"].storage += faction.population

	# Initialize population happiness once at game start
	if population_happiness == -1:
		population_happiness = 100

	on_update_resources()


func calculate_stores():
	for resource in resources.values():
		resource.update_storage()
	global_resources_updated.emit()

	# After storages changed, check population happiness
	check_population_happiness()

	# For each worked WOODS tile, reduce its HP by 1 (same tempo as resource tick)
	if forest_hp_node != null:
		for faction in CityManager.get_all_factions():
			for wt in faction.worked_tiles.values():
				if wt.type == TerrainTilemapLayer.TileTypes.WOODS:
					forest_hp_node.damage(wt.coords, 2)

	# Let planted trees grow a bit each tick (non-worked planted entries)
	if forest_hp_node != null:
		forest_hp_node.growth_tick(1)

	# Note: forest_hp_node should be registered by the terrain generator after creation


func register_forest_hp(node):
	# Store reference to the ForestHP node so ResourceManager can decrement HP over time
	forest_hp_node = node
	print("ResourceManager: forest_hp_node registered: %s" % [forest_hp_node])


signal faction_info_changed(faction_id: int)

func on_update_resources(faction_id: int = -1):
	for resource in resources.values():
		resource.update_change()
	global_resources_updated.emit()
	faction_info_changed.emit(faction_id)
	
func use_resources(type : String, number : int):# gets number of type resource from the storage
	var current = resources[type].storage
	current = current - number
	resources[type].storage = current
	global_resources_updated.emit()

	# resource changed manually -> evaluate happiness
	check_population_happiness()

func how_much_resource(type : String):
	return resources[type].storage


func check_population_happiness() -> void:
	# Ensure happiness initialized
	if population_happiness == -1:
		population_happiness = 100

	#if population_happiness <= 0:
	#	print("GAME OVER! Population happiness dropped below 0")
		
	# If either food or energy is negative, reduce happiness by 5 (floor 0)
	if how_much_resource("food") < 0 or how_much_resource("energy") < 0:
		population_happiness = max(0, population_happiness - 5)
		#print("WARNING! Population happiness is dropping: %d" % population_happiness)



	
	if (how_much_resource("food") /2 > how_much_resource("population")) and how_much_resource("energy")/2> how_much_resource("population"):
		population_happiness += 5
		#print("Population happiness increased: %d" % population_happiness)
		#print("Population happiness increased: %d" % population_happiness)

func get_happiness():
	return population_happiness
		
