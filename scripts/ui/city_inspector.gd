class_name CityInspector extends Control

@export var debug: bool = false
@export var city_label: Label

@export var population_info: PropertyInfo
@export var food_info: PropertyInfo
@export var energy_info: PropertyInfo

func _on_faction_picked(faction_id: int) -> void:
	if debug:
		print("faction %d picked" % faction_id)
	city_label.text = "City %d" % faction_id

	var faction_info: Faction = CityManager.get_faction(faction_id)
	
	if debug: 
		faction_info.print()
	
	population_info.set_label(str(faction_info.population))
	food_info.set_label(str(faction_info.food_requirement))
	energy_info.set_label(str(faction_info.energy_requirement))

	
