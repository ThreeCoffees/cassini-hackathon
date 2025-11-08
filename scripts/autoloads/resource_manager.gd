extends Node

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
		total_yield = CityManager.get_all_factions().reduce(func(sum: int, faction): return sum + faction.get_yields(type), 0)

	func calculate_total_cost():
		total_cost = CityManager.get_all_factions().reduce(func(sum: int, faction): return sum + faction.get_costs(type), 0)
	
	func _init(new_type: String):
		type = new_type
	

var resources: Dictionary[String, ResourceData] = {}

func initialize_resources():
	resources.set("wood", ResourceData.new("wood"))
	resources.set("food", ResourceData.new("food"))
	resources.set("population", ResourceData.new("population"))

	for resource in resources.values():
		resource.update_change()
